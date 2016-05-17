'use strict'

Q = require('q')
request = require('request')
Parser = require('../parser.js')
User = require('../user.js')
async = require('async')
BASE_STEAM_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key='
FULL_PLAYER_URL = BASE_STEAM_URL + process.env.STEAM_API_KEY + '&steamids='
SYSTEM_NAME = 'Steam'

class Steam
  parser = new Parser()
  onlineUsers = []


  constructor: (opts)->
    {
      @slackTeam
    } = opts

    @usersToCheck = @fetchUsers()


  fetchUsers: ->
    return []

  parseUser: (vanityName)->
    deferred = Q.defer()
    request "http://steamcommunity.com/id/#{vanityName}/?xml=1", (error, response, body)=>
      console.log 'error:', error
      console.log 'body:', body
      console.log 'body index:', body.indexOf "The specified profile could not be found." isnt -1
      if body.indexOf("The specified profile could not be found.") isnt -1
        return deferred.reject("Could not find profile matching #{vanityName}")
      parser.parse body, (err, result)->
        console.log 'err:', err
        console.log 'result:', result
        return deferred.resolve(new User({name: result.name, id: result.id, currentSystem: SYSTEM_NAME})) if not err

    deferred.promise

  getOnlineUsers: ->
    onlineUsers = []
    console.log 'users to check:', @usersToCheck
    deferred = Q.defer()
    async.each @usersToCheck, (user, callback)=>
      @isUserOnline(user).then (result)->
        onlineUsers.push(result) if result and not result.error
        callback()
    , (err)->
      deferred.resolve(onlineUsers) if not err

    deferred.promise

  isUserOnline: (user)->
    url = FULL_PLAYER_URL + user.id
    deferred = Q.defer()

    request url, (error, response, body)->
      if !error && response?.statusCode is 200
        parsedResult = JSON.parse(body)
        player = parsedResult.response.players[0]

        return null if not player

        game = player.gameextrainfo
        console.log "player", player
        if game and not user.isPlaying()
          console.log "setting #{user.name} to in game"
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

  saveUser: (user)->
    deferred = Q.defer()
    console.log 'saving:', user
    for u in @usersToCheck
      if u.name is user.name
        console.log 'duplicate'
        deferred.reject('User already added')
        return deferred.promise
    @usersToCheck.push(user)
    console.log 'added a user:', @usersToCheck, user
    deferred.resolve(user.name)
    deferred.promise

  module.exports = Steam
