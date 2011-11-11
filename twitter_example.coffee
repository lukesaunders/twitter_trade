sys = require('sys')
twitter = require('twitter')

twit = new twitter
  consumer_key: '1rPWl8vW13V74Hx3YnyAuA'
  consumer_secret: 'MT9tkQp1uLK3p70VnSbwUImYAspN66pfjzb1dczUk'
  access_token_key: '293170581-hOHBGkDCr94HmETqUgxb3pmfazah10QwsXkKvGPs'
  access_token_secret: 'dd7agCe3GVyqVxRd3RS0202KNwv4i6ba9go0xU7WsQ'

twit.get '/friends/ids.json', {screen_name:'michaeledge', include_entities:true}, (data) ->
  sys.puts(sys.inspect(data))
  friend_ids = data['ids']
  while friend_ids.length > 0
    new_ids = friend_ids.splice(0, 100)
    sys.puts("new_ids length: #{new_ids.length}")
    twit.get '/users/lookup.json', {user_id:new_ids.join(','), include_entities:true}, (data) ->
      sys.puts(sys.inspect(data))

# twit.get '/statuses/user_timeline.json', {screen_name:'michaeledge', include_entities:true}, (data) ->
#  sys.puts(sys.inspect(data))
