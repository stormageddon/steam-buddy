request = require('request');
http = require('http');
Parser = require('./parser.js');
Slack = require('slack-client');

parser = new Parser();

usersToCheck = [
  '76561198024956371' #abattoir
  '76561198081408345' #mother confessor
  '76561198013610944' #onion knight
  '76561198009215427' #stiny
  '76561198191717482' #ruthless_kitten
  ]

currOnline = []

token = process.env.SLACK_TOKEN
slack = new Slack(token, true, true)
currentChannel = null

slack.on('open', (data)->
  console.log 'Connected'

  channels = (channel for id, channel of slack.channels when channel.is_member)

  currentChannel = channels[0];
  console.log 'channel:',currentChannel, typeof currentChannel
)

slack.on('error', (err)->
  console.log('error!', err);
)

slack.login()


minutes = .1
the_interval = minutes * 60 * 1000 #60 seconds

setInterval( (->
  sendMessage user for user in usersToCheck
), the_interval)

sendMessage = (steamIdToCheck)->
  url = TEST_URL + steamIdToCheck;
  console.log 'id to check:', steamIdToCheck
  request(url, (error, response, body)->
    if (!error && response.statusCode == 200)
      parsedResult = JSON.parse(body)
      player = parsedResult.response.players[0]

      return if not player

      playerId = player.steamid
      playerName = player.personaname
      game = player.gameextrainfo;

      if (game)
        console.log('%s is playing %s',playerName,game)

        if (!userIsInGame(playerId))
          messageText = playerName + ' is playing ' + game + '! Go join him!';
          notify(messageText);
          currOnline.push(playerId);

      else
        currOnline.splice(currOnline.indexOf(playerId), 1) if userIsInGame(playerId)
  )

TEST_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9186ADF14E6553A2257FAC4856F822EA&steamids=';



addUser = (vanityName, callback)->
  request('http://steamcommunity.com/id/' + vanityName + '/?xml=1', (error, response, body)->
    parser.parse(body, (err, result)->
      usersToCheck.push(result)
    )
  )

userIsInGame = (playerId)->
  currOnline.indexOf(playerId) >= 0

notify = (message)->
  console.log 'notifying', message, currentChannel
  currentChannel.send(message) if currentChannel
