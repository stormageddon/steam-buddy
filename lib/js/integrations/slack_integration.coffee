Slack = require('slack-client')
require('events').EventEmitter
config = require('../../../config.json').slack;

class SlackIntegration

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
      #event.emit()


  sendNotification: (player, game)->
    return if not @config_channels or not @slack_channels

    channels = @getChannelsToNotify(player)
    message = config.message.replace('#{player}', player).replace('#{game}', game)
    channel.send(message) for channel in channels

  getChannelsToNotify: (player)=>
    userChannels = (channel for channel in @config_channels when channel.indexOf(player) isnt -1)
    notifyChannels = (channel for channel in @slack_channels when userChannels[channel.name] isnt -1)

    notifyChannels


  module.exports = SlackIntegration
