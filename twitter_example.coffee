sys = require('sys')
twitter = require('ntwitter')
models = require("./models")
redis = require("redis")
client = redis.createClient()

accessJSON = file.read('access.json');
accessTokens = JSON.parse(accessJSON)
console.log accessTokens
mongoose = require('mongoose')
mongoose.connect('mongodb://localhost/twitter_example');
client.set('user_queue_timeout', 10000)
bp = mongoose.model('BlogPost')
sys.puts(sys.inspect(bp))

twitterClients = []
for token in accessTokens
  twitterClients.push(
    new twitter
      consumer_key: 'GBqrRS9OKBWsu2ngijdSA'
      consumer_secret: 'QqatfV29TSLpPU4dXNz3W60YAzfxTjc5pMATzHA6qM'
      access_token_key: token['access_token']
      access_token_secret: token['secret']
  )

twitterClient = ->
  return twitterClients[Math.floor(Math.random() * twitterClients.length)]

TwitterUser = mongoose.model('TwitterUser')
userQueue = []

findOrCreateUser = (item, callback, apiType) ->
  TwitterUser.count { twitter_id: item['id_str'] }, (err, count) ->
    #sys.puts("#{item['screen_name']} has #{count}")

    #sys.puts(sys.inspect(item))
    if count == 0
      # sys.puts "creating new user for #{item['screen_name']}"
      newUser = new TwitterUser({api_type: apiType})
      newUser.screen_name = item['screen_name']
      newUser.twitter_id = item['id_str']
      newUser.location = item['location']
      newUser.description = item['description']
      newUser.save (err) ->
        if err
          sys.puts "error was #{sys.inspect(err)}"
      if newUser.location && ((newUser.location.search(/portsmouth/i) != -1) || (newUser.location.search(/southsea/i) != -1) || (newUser.location.search(/havant/i) != -1))
        if (newUser.location.search('NH') != -1) || (newUser.location.search(', nh') != -1) || (newUser.location.search('N.H') != -1) || (newUser.location.search('VA') != -1) || (newUser.location.search(/new hampshire/i) != -1) || (newUser.location.search(/virginia/i) != -1)
          console.log("skipping #{newUser.location}")
        else
          console.log("location match: #{newUser.location}: #{newUser.screen_name}")
          client.rpush('user_queue', newUser.screen_name)
      if callback
        callback(newUser)
    else
      TwitterUser.findOne {twitter_id: item['id_str']}, (err, user) ->
        if callback
          callback(user)

getFriends = (screenName) ->
  sys.puts("getting friends for #{screenName}")
  twit = twitterClient()
  twit.get '/friends/ids.json', {screen_name:screenName, include_entities:true}, (err, data) ->
    if not err and data['ids']
      friend_ids = data['ids']
      totalFriends = friend_ids.length
      while friend_ids.length > 0
        new_ids = friend_ids.splice(0, 100)
        twit.get '/users/lookup.json', {user_id:new_ids.join(','), include_entities:true}, (err, items) ->
          if not err
            for item in items
              findOrCreateUser(item, null, 'friend')
    else
      sys.puts("an error occurred #{sys.inspect(err)}")
      client.rpush('user_queue', screenName)
    setTimeout(checkUserQueue, (Math.floor(Math.random() * 6000)))

checkUserQueue = ->
  client.llen('user_queue', (err, len) ->
    console.log("queue size is #{len}")
  )
  client.lpop('user_queue', (err, nextItem) ->
    if nextItem
      getFriends(nextItem)
  )


checkUserQueue()

monitorStream = ->
  twitterClient().stream 'statuses/sample', (stream) ->
    console.log("initialised", stream)
    stream.on 'data', (data) ->
      findOrCreateUser(data['user'], (user) ->
        user.tweets.addToSet {text: data['text'], status_id: data['id'], tweeted_at: data['created_at'] }
        user.save()
        #console.log("#{user.location}: #{user.screen_name}")
      , 'steam')
