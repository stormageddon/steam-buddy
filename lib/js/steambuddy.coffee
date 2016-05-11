request = require('request');
http = require('http');
Parser = require('./parser.js');
config = require('../../config.json');
parser = new Parser();
SlackIntegration = require('./integrations/slack_integration.js')
User = require('./user.js')
$q = require('q')
async = require('async')

STEAM_API_TOKEN = process.env.STEAM_API_TOKEN
BASE_STEAM_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key='
FULL_PLAYER_URL = BASE_STEAM_URL + process.env.STEAM_API_KEY + '&steamids='
XBOX_API_TOKEN = process.env.XBOX_API_TOKEN
BASE_XBOX_URL = 'https://xboxapi.com/v2/'

integrations = []

init = ->
  console.log '##### Environment variables:'
  console.log '## Slack Token:', process.env.SLACK_TOKEN
  console.log '## Steam API Key:', process.env.STEAM_API_KEY
  console.log '## XBox API Token:', process.env.XBOX_API_TOKEN
  console.log '####################'
  integrations.push(new SlackIntegration({token: process.env.SLACK_TOKEN}))

  usersToCheck = []
  ((parseUser(user).then (result)-> usersToCheck.push(result)) for user in config.users)

  xboxUsers = config.xbox.users


  minutes = .1
  the_interval = minutes * 60 * 1000 #10 seconds
  setInterval( (=>
    getOnlineUsers(usersToCheck)
  ), the_interval)

  xbox_interval = .3 * 60 * 1000 # every 30 seconds
  setInterval( (=> # XBox interval
    checkXBoxUsers(xboxUsers)
  ), xbox_interval)

sendNotifications = (user)->
  integration.sendNotification(user.name, user.currentGame) for integration in integrations

checkXBoxUsers = (xboxUsers)->
  deferred = $q.defer()

  async.each xboxUsers, (userId, callback)->
    xboxUrl = BASE_XBOX_URL + userId + '/presence'
    request {
      uri: xboxUrl,
      headers:
        'Content-Type': 'application/json'
        'X-Auth': XBOX_API_TOKEN
    }, (error, response, body)->
      result = JSON.parse(response.body)

      return if result.state isnt 'Online'

      console.log 'result:', result.devices?[0].titles[0]

      # loop through titles
      for title in result.devices?[0]?.titles
        activeGame = title?.name if title?.placement is 'Full'

      #activeGame = result.devices?[0].titles[1]?.name
      game = result.devices[0].titles[1]?.name if activeGame?
      console.log 'active game:', activeGame
      if result.state is 'Online' and activeGame? and activeGame isnt 'Home' and activeGame isnt 'Netflix' #and result.devices.titles[0] isnt 'Home'
        getXboxUserName(userId, game).then (data)=>
          currUser = xboxUsers[userId]
          console.log 'data', data
          console.log 'currUser', currUser
          if not currUser
            currUser = new User(name: data.name, id: userId)
            xboxUsers[userId] = currUser
            console.log 'currUser2:', currUser
            console.log 'currUser2:', currUser.isPlaying()
          if currUser.isPlaying()
            currUser.setInactive() if data.game isnt currUser.currentGame
            xboxUsers[userId] = currUser
            return
          currUser.setInGame(data.game)
          console.log 'Sending notification: ' + data.name + ' is playing ' + data.game
          sendNotifications(name: data.name, currentGame: data.game) if data.name
          #sendXBoxNotification(data.name, data.game) if data.name
          callback()
      else
        callback()
  , (err, result)->
    console.log('err:', err)
    console.log('result:', result)
  deferred.promise

getXboxUserName = (userId, game)->
  deferred = $q.defer()
  profileUrl = BASE_XBOX_URL + userId + '/profile'
  request {
    uri: profileUrl,
    headers:
      'Content-Type': 'application/json'
      'X-Auth': XBOX_API_TOKEN
  }, (error, response, body)->
    gamerTag = JSON.parse(body).GameDisplayName

    if error
      console.log 'Error fetching gamer tag'
      return null
    return deferred.resolve(name: gamerTag, game: game)
  deferred.promise

getOnlineUsers = (allUsers)->
  onlineUsers = []
  deferred = $q.defer()
  async.each allUsers, (user, callback)->
    isUserOnline(user).then (result)->
      onlineUsers.push(result) if result and not result.error
      callback()
  , (err)->
    sendNotifications(user) for user in onlineUsers if not err
    deferred.resolve(onlineUsers) if not err

  deferred.promise

isUserOnline = (user)->
  url = FULL_PLAYER_URL + user.id
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
      console.log 'An error was encountered at', Date.now()
      console.log 'status code:', response.statusCode
      console.log 'url:', url
      deferred.reject(error)

  deferred.promise

parseUser = (vanityName)->
  deferred = $q.defer()
  request "http://steamcommunity.com/id/#{vanityName}/?xml=1", (error, response, body)=>
    parser.parse body, (err, result)->
      deferred.resolve(new User({name: result.name, id: result.id})) if not err

  deferred.promise

status = ->
  console.log 'Checking status of connections'
  deferred = $q.defer()
  $q.spread (integration.isConnected() for integration in integrations), (result)->
    console.log 'result:', result
    deferred.resolve(result)
  deferred.promise

module.exports =
  init: init
  status: status
