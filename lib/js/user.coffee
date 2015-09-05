'use strict'

class User
  onlineUsers = []

  constructor: (opts)->
    {
      @name
      @id
    } = opts

    @inGame = no
    @currentGame = null

  isPlaying: ->
    return @inGame

  setInGame: (gameName)->
    @inGame = yes
    @currentGame = gameName
    onlineUsers.push(this)

  setInactive: ->
    @inGame = no
    @currentGame = null
    onlineUsers.splice(onlineUsers.indexOf(@id), 1)

  module.exports = User
