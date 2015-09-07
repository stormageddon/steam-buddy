# Steam Buddy

## Description
Steam buddy is a small node bot that watches for Steam users to join a game. When a member starts playing a game, Steam Buddy sends out notifications to let all of their friends know they are starting to play. Steam Buddy is currently configured to integrate with slack chat, but there are plans to extend Steam Buddy's functionality to include other means of communication.


Get notified immediately when your friends begin playing a steam game!
![Steam Buddy Screenshot](/img/steam_buddy.png)

## Configuration
Steam Buddy currently uses a simple configuration file to store information like Slack channels and Steam usernames. An example configuration file:

    {
      "users": ["user_1", "Steam_User", "Sam_Sample123", "1234567890123456789"],
	  "slack": {
	    "message": "#{player} is playing #{game}! Go join them!",
	    "channels": {
		  "general": ["User 1", "Steam User", "Sam Sample123"]
	    }
	  }	
	}

`users` - In this section, you should list all of the Steam IDs that you want Steam Buddy to monitor. Steam buddy will use this Steam ID to lookup the 64-bit ID as well as the users configured Steam Display Name when sending out notifications. The Steam ID should be the vanity url taht is configured for a user. To find the vanity url, simply go to a users profile page and take the last portion of the url: `http://steamcommunity.com/id/THE_VANITY_URL/`. This will either be a custom url set by the user or the users steam id. Either one will work.

`slack` - Identify a slack integration. You can configure various options for when sending out a slack notification in this section.

  `message` - The message that will be sent out to all slack channels Steam Buddy is in. The message must include the `#{player}` and `#{game}` tags. These tags will be replaced with the name of the user signing into a game, and the game that they have launched.

  `channels` - In this section you should list all channels that you want Steam Buddy to send out notifications on. The channels should be a JSON object with the channel name as the id, and a list of Steam Display Names that will be in the messages that are sent out.


## Configuring for slack
In order for Steam Buddy to send Slack messages, it needs to be set up as a slack bot. Simply add a new bot integration to your slack team and set the channel(s) that you want Steam Buddy to run on. Save the integration and set the generated slack token as an environment variable: `export SLACK_TOKEN="abcd-1234-abcd-1234"`. Steam Buddy will read this token in when launched and use it to authenticate into Slack and send messages.


## Running Steam Buddy
1. Clone the Steam Buddy repository.
2. Set up the configuration file (see Configuration section above)
3. run `npm install` to install all dependencies
4. run `make run` to run steam buddy

It is suggested you run Steam Buddy as a daemon using something like screens or supervisord.

## Todo
1. Break out some of the constants that are stored in plaintext
2. Clean up and modularize the code

## Future features
1. Allow users to open the steam game from the message
2. Allow easy addition of new steam users to watch
3. Allow easy configuration of steam users, steam games, and Slack channels
4. Upgrade to node 1.0.x

## License
The MIT License (MIT)

Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
