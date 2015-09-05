request = require('request');
http = require('http');
Parser = require('./parser.js');
config = require('../../config.json');
parser = new Parser();
SlackIntegration = require('./integrations/slack_integration.js')
User = require('./user.js')
$q = require('Q')
async = require('async')

PLAYER_SUMMARY_URL = process.env.PLAYER_SUMMARY_URL

integrations = []

init = ->
  integrations.push(new SlackIntegration({token: process.env.SLACK_TOKEN}))

  usersToCheck = []
  usersToCheck = (new User({name: user, id: id}) for id, user of config.users)

  minutes = .1
  the_interval = minutes * 60 * 1000 #10 seconds
  setInterval( (=>
    getOnlineUsers(usersToCheck)
  ), the_interval)

sendNotifications = (user)->
  integration.sendNotification(user.name, user.currentGame) for integration in integrations

parseUsers = (usersToCheck)->
  usersToCheck.push(new User({name: user, id: id})) for id, user of config.users
  usersToCheck


getOnlineUsers = (allUsers)->
  onlineUsers = []
  deferred = $q.defer()
  async.each allUsers, (user, callback)->
    isUserOnline(user).then (result)->
      onlineUsers.push(result) if result

      callback()
  , (err)->
    sendNotifications(user) for user in onlineUsers if not err
    deferred.resolve(onlineUsers) if not err

  deferred.promise

isUserOnline = (user)->
  url = PLAYER_SUMMARY_URL + user.id
  deferred = $q.defer()

  request url, (error, response, body)->
    if !error && response.statusCode is 200
      parsedResult = JSON.parse(body)
      player = parsedResult.response.players[0]

      return null if not player

      game = player.gameextrainfo

      if game and not user.isPlaying()
        user.setInGame(game)
        deferred.resolve(user)

      else if not game
        user.setInactive()
        deferred.resolve(null)
    else
      console.log 'An error was encountered', error
      return error

  deferred.promise

init()
