Slack = require('slack-client')
require('events').EventEmitter
config = require('../../../config.json').slack;
Steam = require('../systems/steam.js')

class SlackIntegration
  DEFAULT_MESSAGE = '#{player} is playing #{game}. Go join them!'
  VALID_COMMANDS = { ADD: 'add', ONLINE: 'online' }

  # each slack connection needs to store the users it cares about
  usersToCheck = []

  constructor: (opts, User)->
    {
      @token
    } = opts
    @User = User
    @slack = new Slack(@token, true, true)
    @slack.login()
    @slack_channels = []
    @steam = null

    @slack.on 'error', (err)->
      console.log 'Slack error!', err

    @slack.on 'open', (data)=>
      console.log 'Bot id:', @slack.self.id
      console.log 'User:', @User
      @id = @slack.self.id
      @steam = new Steam(slackTeam: @id)
      @slack_channels = (channel for id, channel of @slack.channels when channel.is_member)

    @slack.on 'message', (message)=>
      channel = @slack.getChannelGroupOrDMByID(message.channel)

      isCommand = message.text.indexOf("@#{@id}") isnt -1
      console.log 'was it a command?', isCommand
      return if not isCommand
      @parseCommand(message.text, channel)

    @slack.on 'close', (data)->
      console.log 'Slack connection closed, waiting for reconnect', data
      @slack.login() # Attempt to log back in

  parseCommand: (command, channel)->
    console.log 'parsing command', command
    commandArr = command.split(' ')
    console.log 'command arr:', commandArr
    commandAction = VALID_COMMANDS[commandArr[1].toUpperCase()]
    return console.log 'Unknown command' if not commandAction

    if commandAction is VALID_COMMANDS.ADD
      console.log 'add command'
      system = commandArr[2].toLowerCase()
      newUser = commandArr[3]
      console.log "adding #{newUser} with system #{system}"

      if system is 'steam'
        @steam.parseUser(newUser).then (user)=>
          console.log 'adding a new user!', user
          @steam.saveUser(user)

      else
        @sendMessage("#{system} is not a supported gaming environment", channel)

      return

    if commandAction is VALID_COMMANDS.ONLINE
      console.log 'online command'

      users = @User.getOnlineUsers()
      console.log 'returning online users:', users

      if users.length > 0
        onlineMessage = 'Users currently in game:'
        for user in users
          onlineMessage += "\n#{user.name} is online playing #{user.currentGame}"
          onlineMessage += " (#{user.currentSystem})" if user.currentSystem
        console.log 'online message:', onlineMessage
        @sendMessage(onlineMessage, channel)
      else
        @sendMessage('No users currently in game', channel)
      return

  sendMessage: (message, channel)->
    channel.send(message)

  sendNotification: (player, game)->
    #channels = @getChannelsToNotify(player)
    console.log 'config:', config
    #message = if config.message then formatMessage(config.message, player, game) else formatMessage(DEFAULT_MESSAGE, player, game)
    message = "#{player} is playing #{game}. Go join them!"
#    console.log 'sending + channel length', channels.length
    console.log 'slack channels:', @slack_channels
    channel.send(message) for channel in @slack_channels

  formatMessage: (message, player, game)->
    console.log 'formatting message', message, player, game
    message.replace('#{player}', player)
    message.replace('#{game}', game)
    message

  isConnected: ->
    @slack.connected

  checkOnlineUsers: ->
    @steam.getOnlineUsers().then (onlineUsers)=>
      console.log 'need to notify for:', onlineUsers
      @sendNotification(user.name, user.currentGame) for user in onlineUsers

  module.exports = SlackIntegration
