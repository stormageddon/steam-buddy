# Steam Buddy

## Description
Steam buddy is a small node bot that watches for Steam users to join a game. When a member starts playing a game, Steam Buddy sends out notifications to let all of their friends know they are starting to play. Steam Buddy is currently configured to integrate with slack chat, but there are plans to extend Steam Buddy's functionality to include other means of communication.


Get notified immediately when your friends begin playing a steam game!
![Steam Buddy Screenshot](/img/steam_buddy.png)

## Configuration
Steam Buddy currently uses a simple configuration file to store information like Slack channels and Steam usernames. An example configuration file:

    {
        "users": ["user_1", "Steam_User", "Sam_Sample123"],
	    "channels": {
		    "general": ["User 1", "Steam User", "Sam Sample123"]
		}
	}

`users` - In this section, you should list all of the Steam ID that you want Steam Buddy to monitor. Steam buddy will use this Steam ID to lookup the 64-bit ID as well as the users configured Steam Display Name when sending out notifications.

`channels` - In this section you should list all channels that you want Steam Buddy to send out notifications on. The channels should be a JSON object with the channel name as the id, and a list of Steam Display Names that will be in the messages that are sent out.

## Todo
1. Break out some of the constants that are stored in plaintext
2. Clean up and modularize the code

## Future features
1. Allow users to open the steam game from the message
2. Allow easy addition of new steam users to watch
3. Allow easy configuration of steam users, steam games, and Slack channels
4. Upgrade to node 1.0.x
