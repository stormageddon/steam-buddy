Slack = require('slack-client')
require('events').EventEmitter
config = require('../../../config.json');

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
      console.log 'READING MESSAGE: ', message?.text
      channel = @slack.getChannelGroupOrDMByID(message.channel)
      console.log 'Channel: ', channel
      #event.emit()


  sendNotification: (player, game)->
    console.log 'send for channels', @slack_channels
    return if not @config_channels or not @slack_channels
    console.log 'should send'
    channels = @getChannelsToNotify(player)
    message = "#{player} is playing #{game}! Go join them!"
    channel.send(message) for channel in channels

  getChannelsToNotify: (player)=>
    console.log 'Getting channels to notify'
    userChannels = (channel for channel in @config_channels when channel.indexOf(player) isnt -1)
    console.log 'slack channels:', @slack_channels.length
    notifyChannels = (channel for channel in @slack_channels when userChannels[channel.name] isnt -1)

    notifyChannels


  module.exports = SlackIntegration
