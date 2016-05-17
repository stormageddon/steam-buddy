Slack = require('slack-client')
require('events').EventEmitter
config = require('../../../config.json').slack;
Steam = require('../systems/steam.js')
pkg = require('../../../package.json')

class SlackIntegration
  DEFAULT_MESSAGE = '#{player} is playing #{game}. Go join them!'
  VALID_COMMANDS = { ADD: 'add', ONLINE: 'online' }

  # each slack connection needs to store the users it cares about
  usersToCheck = []
  NUM_USERS_ADDED = 0
  MAX_USERS = 5

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
      @id = @slack.self.id
      @steam = new Steam(slackTeam: @id)
      @slack_channels = (channel for id, channel of @slack.channels when channel.is_member)
      @sendMessage("I'm live! Running version #{pkg.version}", @slack_channels[0])

    @slack.on 'message', (message)=>
      channel = @slack.getChannelGroupOrDMByID(message.channel)
      isCommand = message?.text?.indexOf("@#{@id}") isnt -1
      return if not isCommand or not message or not message.text
      @parseCommand(message.text, message.user, channel)

    @slack.on 'close', (data)->
      console.log 'Slack connection closed, waiting for reconnect', data
      @slack.login() # Attempt to log back in

  parseCommand: (command, sendingUser, channel)->
    commandArr = command.split(' ')
    console.log 'first arg:', commandArr[0]
    console.log 'first arg:', @id
    console.log 'first arg:', commandArr[0] is "@{@id}"
    return if not @id or commandArr[0].indexOf("@#{@id}") is -1
    commandAction = VALID_COMMANDS[commandArr[1]?.toUpperCase()]
    return @sendMessage("`#{commandArr[1]}` is not a known command", channel) if not commandAction

    if commandAction is VALID_COMMANDS.ADD

      return @sendMessage("You already have #{MAX_USERS}. Please upgrade to premium to add more :kappa:", channel) if NUM_USERS_ADDED is MAX_USERS

      system = commandArr[2]?.toLowerCase()
      newUser = commandArr[3]

      return @sendMessage("Adding a user must be of format `add <system> <username>`", channel) if not newUser

      if system is 'steam'
        @steam.parseUser(newUser).then (user)=>
          user.slackUser = sendingUser
          @steam.saveUser(user)
        .then (username)=>
          NUM_USERS_ADDED++
          @sendMessage("#{username} has been added successfully.", channel)
        .catch (err)=>
          console.log 'error in add user', err
          @sendMessage(err, channel)

      else
        @sendMessage("#{system} is not a supported gaming environment", channel)

      return

    if commandAction is VALID_COMMANDS.ONLINE
      users = @User.getOnlineUsers()

      if users.length > 0
        onlineMessage = 'Users currently in game:'
        for user in users
          username = @slack.users[user.slackUser].name
          onlineMessage += "\n#{username} (#{user.name}) is online playing #{user.currentGame}"
          onlineMessage += " (#{user.currentSystem})" if user.currentSystem
        @sendMessage(onlineMessage, channel)
      else
        @sendMessage('No users currently in game', channel)
      return

  sendMessage: (message, channel)->
    channel.send(message)

  sendNotification: (user, game, system)->
    username = @slack.users[user.slackUser].name
    message = "@#{username} (#{user.name}) is playing #{game}"
    message += " on #{system}" if system
    message += ". Go join them!"
    channel.send(message) for channel in @slack_channels

  formatMessage: (message, player, game)->
    message.replace('#{player}', player)
    message.replace('#{game}', game)
    message

  isConnected: ->
    @slack.connected

  checkOnlineUsers: ->
    @steam.getOnlineUsers().then (onlineUsers)=>
      @sendNotification(user, user.currentGame, user.currentSystem) for user in onlineUsers

  module.exports = SlackIntegration
