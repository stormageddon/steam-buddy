Slack = require('slack-client')

class SlackIntegration

  constructor: (opts)->
    {
      @token
    } = opts

    console.log "creating slack integration with token #{@token}"
    @slack = new Slack(@token, true, true)
    @slack.login()
    @channels = [] # Populate channels here

    @slack.on 'error', (err)->
      console.log 'Slack error!', err

    @slack.on 'open', (data)->
      console.log 'Slack data:', data

  sendNotification: (player, game)->
    console.log "Sending slack notification for #{player} in #{game}"
    return if not @channels or not @channels.length > 0
    channel.send("#{player} is playing #{game}! Go join them!") for channel in @channels

  module.exports = SlackIntegration
