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
      console.log 'Slack connection closed, waiting for reconnect'


  sendNotification: (player, game)->
    return if not @config_channels or not @slack_channels

    channels = @getChannelsToNotify(player)

    message = if config.message then formatMessage(config.message, player, game) else formatMessage(DEFAULT_MESSAGE, player, game)

    channel.send(message) for channel in channels

  getChannelsToNotify: (player)=>
    userChannels = (channel for channel in @config_channels when channel.indexOf(player) isnt -1)
    notifyChannels = (channel for channel in @slack_channels when userChannels[channel.name] isnt -1)

    notifyChannels

  formatMessage: (message, player, game)->
    message.replace('#{player}', player)
    message.replace('#{game}', game)
    message

  module.exports = SlackIntegration
