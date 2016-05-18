'use strict'

class User
  User.onlineUsers = []

  constructor: (opts)->
    {
      @name #username
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
    console.log 'online users1:', User.onlineUsers

  setInactive: ->
    return if User.onlineUsers.indexOf(this) is -1

    @inGame = no
    @currentGame = null
    console.log 'removing user'

    User.onlineUsers.splice(User.onlineUsers.indexOf(this), 1)

  @getOnlineUsers: ->
    console.log 'online users:', User.onlineUsers
    return User.onlineUsers

  module.exports = User
