mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

BlogPost = new Schema
  author: ObjectId
  title: String
  body: String
  date: Date

Tweet = new Schema
  text: String
  status_id: { type: String }
  tweeted_at: Date
  created_at: { type: Date, default: Date.now }

TwitterUser = new Schema
  screen_name: { type: String, index: true }
  twitter_id: { type: String, unique: true }
  location: String
  description: String
  tweets: [Tweet]
  created_at: { type: Date, default: Date.now }

mongoose.model('BlogPost', BlogPost)
mongoose.model('TwitterUser', TwitterUser)