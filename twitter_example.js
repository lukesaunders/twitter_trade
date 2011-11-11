var sys = require('sys');
var twitter = require('twitter');

var twit = new twitter({
  consumer_key: '1rPWl8vW13V74Hx3YnyAuA',
  consumer_secret: 'MT9tkQp1uLK3p70VnSbwUImYAspN66pfjzb1dczUk',
  access_token_key: '293170581-hOHBGkDCr94HmETqUgxb3pmfazah10QwsXkKvGPs',
  access_token_secret: 'dd7agCe3GVyqVxRd3RS0202KNwv4i6ba9go0xU7WsQ'
});

twit.get('/statuses/user_timeline.json', {screen_name:'michaeledge', include_entities:true}, function(data) {
    sys.puts(sys.inspect(data));
});