'use strict'

Q = require('q')
request = require('request')
Parser = require('../parser.js')
User = require('../user.js')
async = require('async')
BASE_STEAM_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key='
FULL_PLAYER_URL = BASE_STEAM_URL + process.env.STEAM_API_KEY + '&steamids='
SYSTEM_NAME = 'Steam'
psql = require('../dao/DAO.js').POSTGRESQL
db = new psql()

class Steam
  parser = new Parser()
  onlineUsers = []


  constructor: (opts)->
    {
      @slackTeam
      @slackToken
    } = opts

    @usersToCheck = []
    @fetchUsers().then (users)=>
      @usersToCheck = users
    .catch (err)->
      console.log 'error fetching:', err

  fetchUsers: ->
    deferred = Q.defer()
    db.getUsersForToken(@slackToken, 'steam').then (userRows)->
      users = []
      for user in userRows.users
        currUser = new User(name: user.username, accountName: user.steamvanity, id: user.steamid)
        currUser.currentSystem = 'steam'
        currUser.slackUser = user.slackid
        users.push(currUser)
      deferred.resolve(users)
    return deferred.promise

  parseUser: (vanityName)->
    deferred = Q.defer()
    request "http://steamcommunity.com/id/#{vanityName}/?xml=1", (error, response, body)=>
      console.log 'error:', error if error
      console.log 'body index:', body?.indexOf("The specified profile could not be found.") isnt -1
      if body?.indexOf("The specified profile could not be found.") isnt -1
        return deferred.reject("Could not find profile matching #{vanityName}")
      parser.parse body, (err, result)->
        console.log 'err:', err
        console.log 'result:', result
        return deferred.resolve(new User({name: result.name, accountName: vanityName, id: result.id, currentSystem: SYSTEM_NAME})) if not err

    deferred.promise

  getOnlineUsers: ->
    onlineUsers = []
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
        if game and not user.isPlaying()
          console.log "setting #{user.name} to in game"
          user.setInGame(game)
          deferred.resolve(user)

        else if not game
          user.setInactive()
          deferred.resolve(null)
      else
        console.log 'An error was encountered at', Date.now()
        console.log 'status code:', response?.statusCode
        console.log 'url:', url
        deferred.reject(error)

    deferred.promise

  saveUser: (user)->
    deferred = Q.defer()
    #for u in @usersToCheck
    #  if u.name is user.name
    #    deferred.reject('User already added')
    #    return deferred.promise
    db.insertUser(user.name, user.accountName, user.id, user.slackUser, @slackToken).then (result)=>
      @usersToCheck.push(user)
      deferred.resolve(user.name)
    .catch (err)->
      console.log 'failed: ', err.error
      deferred.reject(err.error)

    deferred.promise

  removeUser: (accountName)->
    deferred = Q.defer()
    notFoundMessage = "#{accountName} not found in list of users"
    userToDelete = null

    for user in @usersToCheck
      if user.accountName is accountName
        userToDelete = user
        @usersToCheck.splice(@usersToCheck.indexOf(userToDelete), 1)
        break


    if userToDelete
      db.deleteUser('steamid', userToDelete.id).then (result)->
        deferred.resolve("Successfully removed #{accountName} from watch list")
    else
      deferred.reject(notFoundMessage)
    deferred.promise

  getAllSteamUsers: ->
    return @usersToCheck

  module.exports = Steam
