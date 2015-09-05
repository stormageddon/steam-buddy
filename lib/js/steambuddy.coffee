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

  console.log 'config users:', config.users
  usersToCheck = []
  usersToCheck = (new User({name: user, id: id}) for id, user of config.users)

  console.log 'users to check: ', usersToCheck
  minutes = .1
  the_interval = minutes * 60 * 1000 #10 seconds
  setInterval( (=>
    console.log 'users', usersToCheck
    getOnlineUsers(usersToCheck)
  ), the_interval)

sendNotifications = (user)->
  console.log 'sending muh notification for', user
  integration.sendNotification(user.name, user.currentGame) for integration in integrations

parseUsers = (usersToCheck)->
  usersToCheck.push(new User({name: user, id: id})) for id, user of config.users
  console.log 'populated users:', usersToCheck
  usersToCheck


getOnlineUsers = (allUsers)->
  console.log 'all users:', allUsers
  onlineUsers = []
  deferred = $q.defer()
  async.each allUsers, (user, callback)->
    isUserOnline(user).then (result)->
      console.log 'got a result:', result
      onlineUsers.push(result) if result

      callback()
  , (err)->
    sendNotifications(user) for user in onlineUsers if not err
    deferred.resolve(onlineUsers) if not err

  deferred.promise

isUserOnline = (user)->
  console.log 'Checking user ', user, typeof user
  url = PLAYER_SUMMARY_URL + user.id
  deferred = $q.defer()

  request url, (error, response, body)->
    if !error && response.statusCode is 200
      parsedResult = JSON.parse(body)
      player = parsedResult.response.players[0]

      console.log 'parsed player:', player

      return null if not player

      game = player.gameextrainfo
      console.log 'game:', game

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

sendMessage = (steamIdToCheck)->
  url = TEST_URL + steamIdToCheck;
  console.log 'id to check:', steamIdToCheck
  request(url, (error, response, body)->
    if (!error && response.statusCode == 200)
      parsedResult = JSON.parse(body)
      player = parsedResult.response.players[0]

      return if not player

      playerId = player.steamid
      playerName = player.personaname
      game = player.gameextrainfo;

      if (game)
        console.log('%s is playing %s',playerName,game)

        if (!userIsInGame(playerId))
          messageText = playerName + ' is playing ' + game + '! Go join him!';
          notify(messageText);
          currOnline.push(playerId);

      else
        currOnline.splice(currOnline.indexOf(playerId), 1) if userIsInGame(playerId)
  )

init()
