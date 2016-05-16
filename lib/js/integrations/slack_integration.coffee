Slack = require('slack-client')
require('events').EventEmitter
config = require('../../../config.json').slack;

class SlackIntegration
  DEFAULT_MESSAGE = '#{player} is playing #{game}. Go join them!'
  VALID_COMMANDS = { ADD: 'add', ONLINE: 'online' }

  constructor: (opts, User)->
    {
      @token
    } = opts
    @User = User
    @slack = new Slack(@token, true, true)
    @slack.login()
    @slack_channels = []
    @config_channels = config.channels

    @slack.on 'error', (err)->
      console.log 'Slack error!', err

    @slack.on 'open', (data)=>
      console.log 'Bot id:', @slack.self.id
      console.log 'User:', @User
      @id = @slack.self.id
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
      system = commandArr[2]
      newUser = commandArr[3]
      console.log "adding #{newUser} with system #{system}"
      return
    if commandAction is VALID_COMMANDS.ONLINE
      console.log 'online command'

      users = @User.getOnlineUsers()
      console.log 'returning online users:', users

      if users.length > 0
        onlineMessage = 'Users currently in game:'
        for user in users
          onlineMessage += "\n#{user.name} is online playing #{user.currentGame}"
        console.log 'online message:', onlineMessage
        @sendMessage(onlineMessage, channel)
      else
        @sendMessage('No users currently in game', channel)
      return

  sendMessage: (message, channel)->
    channel.send(message)

  sendNotification: (player, game)->
    console.log 'Send message', @config_channels.length, @slack_channels.length
    #return if not @config_channels or not @slack_channels

    channels = @getChannelsToNotify(player)
    console.log 'config:', config
    #message = if config.message then formatMessage(config.message, player, game) else formatMessage(DEFAULT_MESSAGE, player, game)
    message = "#{player} is playing #{game}. Go join them!"
    console.log 'sending + channel length', channels.length
    channel.send(message) for channel in channels

  getChannelsToNotify: (player)=>
    userChannels = (channel for channel in @config_channels when channel.indexOf(player) isnt -1)
    notifyChannels = (channel for channel in @slack_channels when userChannels[channel.name] isnt -1)

    notifyChannels

  formatMessage: (message, player, game)->
    console.log 'formatting message', message, player, game
    message.replace('#{player}', player)
    message.replace('#{game}', game)
    message

  isConnected: ->
    @slack.connected

  module.exports = SlackIntegration
