'use strict'

psql = require('./dao/DAO.js').POSTGRESQL
db = new psql()

class User
  User.onlineUsers = []

  constructor: (opts)->
    {
      @name #username
      @accountName #login name for steam account
      @id #steamId
      @currentSystem
    } = opts

    @slackUser = null #slackId

    @inGame = no
    @currentGame = null


  isPlaying: ->
    return @inGame

  setInGame: (gameName)->
    @inGame = yes
    @currentGame = gameName
    User.onlineUsers.push(this)

  setInactive: ->
    return if User.onlineUsers.indexOf(this) is -1

    @inGame = no
    @currentGame = null

    User.onlineUsers.splice(User.onlineUsers.indexOf(this), 1)

  @getOnlineUsers: ->
    return User.onlineUsers

  @removeUser: (username)->
    db.deleteUser(username)


  module.exports = User
