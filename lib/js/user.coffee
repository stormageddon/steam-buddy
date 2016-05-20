'use strict'

psql = require('./dao/DAO.js').POSTGRESQL
db = new psql()

class User
  constructor: (opts)->
    {
      @name #username
      @accountName #login name for steam account
      @id #steamId
      @currentSystem
    } = opts

    @onlineUsers = []
    @slackUser = null #slackId

    @inGame = no
    @currentGame = null


  isPlaying: ->
    return @inGame

  setInGame: (gameName)->
    @inGame = yes
    @currentGame = gameName
    @onlineUsers.push(this)
    console.log 'pushed to online users', @onlineUsers

  setInactive: ->
    return if @onlineUsers.indexOf(this) is -1

    @inGame = no
    @currentGame = null

    @onlineUsers.splice(@onlineUsers.indexOf(this), 1)

  @getOnlineUsers: ->
    console.log 'instance users', @onlineUsers
    return @onlineUsers

  @removeUser: (username)->
    db.deleteUser(username)


  module.exports = User
