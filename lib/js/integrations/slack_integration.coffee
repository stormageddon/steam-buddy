Slack = require('slack-client')
require('events').EventEmitter
config = require('../../../config.json').slack;

class SlackIntegration
  DEFAULT_MESSAGE = '#{player} is playing #{game}. Go join them!'

  constructor: (opts)->
    {
      @token
    } = opts
    @slack = new Slack(@token, true, true)
    @slack.login()
    @slack_channels = []
    @config_channels = config.channels

    @slack.on 'error', (err)->
      console.log 'Slack error!', err

    @slack.on 'open', (data)=>
      @slack_channels = (channel for id, channel of @slack.channels when channel.is_member)

    @slack.on 'message', (message)=>
      channel = @slack.getChannelGroupOrDMByID(message.channel)

    @slack.on 'close', (data)->
      console.log 'Slack connection closed, waiting for reconnect', data
      @slack.login() # Attempt to log back in


  sendNotification: (player, game)->
    console.log 'player and game:', player, game
    console.log 'Send message', @config_channels.length, @slack_channels.length
    #return if not @config_channels or not @slack_channels

    channels = @getChannelsToNotify(player)
    console.log 'config:', config
    #message = if config.message then formatMessage(config.message, player, game) else formatMessage(DEFAULT_MESSAGE, player, game)
    message = "#{player} is playing #{game}. Go join them!"
    console.log 'sending + channel length', channels.length
    console.log 'message for slack:', message
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
