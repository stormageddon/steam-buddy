# Steam Buddy

## Description
Steam buddy is a small node bot that watches for Steam users to join a game. When a member starts playing a game, Steam Buddy sends out notifications to let all of their friends know they are starting to play. Steam Buddy is currently configured to integrate with slack chat, but there are plans to extend Steam Buddy's functionality to include other means of communication.

Get notified immediately when your friends begin playing a steam game!
![Steam Buddy Screenshot](/img/steam_buddy.png)

## Using Steam Buddy
Steam Buddy will run silently, constantly listening for input from either users within your team channel, or for a user to launch a game on one of the supported systems. Interacting with steam buddy is easy - just @ him! Assuming you name your integration steam_buddy, you can:

`@steam_buddy: add steam my_steam_user` - Adds a steam user for your channel to be notified about.

`@steam_buddy: remove my_steam_user` - Removes a steam user that your channel was previously being notified about.

`@steam_buddy: online` - Lists any users currently in game.

## ~~Configuration (DEPRECATED)~~
~~Steam Buddy currently uses a simple configuration file to store information like Slack channels and Steam usernames. An example configuration file:

    {
      "users": ["user_1", "Steam_User", "Sam_Sample123", "1234567890123456789"],
	  "slack": {
	    "message": "#{player} is playing #{game}! Go join them!",
	    "channels": {
		  "general": ["User 1", "Steam User", "Sam Sample123"]
	    }
	  }	
	}

`users` - In this section, you should list all of the Steam IDs that you want Steam Buddy to monitor. Steam buddy will use this Steam ID to lookup the 64-bit ID as well as the users configured Steam Display Name when sending out notifications. The Steam ID should be the vanity url that is configured for a user. To find the vanity url, simply go to a users profile page and take the last portion of the url: `http://steamcommunity.com/id/THE_VANITY_URL/`. This will either be a custom url set by the user or the users steam id. Either one will work.

`slack` - Identify a slack integration. You can configure various options for when sending out a slack notification in this section.

  `message` - The message that will be sent out to all slack channels Steam Buddy is in. The message must include the `#{player}` and `#{game}` tags. These tags will be replaced with the name of the user signing into a game, and the game that they have launched.

  `channels` - In this section you should list all channels that you want Steam Buddy to send out notifications on. The channels should be a JSON object with the channel name as the id, and a list of Steam Display Names that will be in the messages that are sent out.~~

## Configuration for Steam Buddy 2.0
As of version 2.0, Steam Buddy no longer stores information in a configuration file. Instead, you must run a db. Currently only Postgres is supported, although you can easily make your own db integration and add it to the `DAO` directory.

The reason Steam Buddy has moved to an actual database is because it allows Steam Buddy to grow. A configuration file is tricky to manage manually and required you to do a lot of manual mapping of usernames to id's. With a database, Steam Buddy can handle all of it, while also gaining the very useful ability to easily add new users and to restore the users it is watching should it crash.

## Setting up Postgres
The Postgres setup for Steam Buddy is actually very easy. It has 1 required table, and 1 optional table. The required table is `sb_user`, and is where all of the slack users that Steam Buddy is tracking are stored. The schema that you should setup for `sb_user` is this:

` id |     username     |      steamid      |     steamvanity      |  slackid  |              integration_fk               
----+------------------+-------------------+----------------------+-----------+-------------------------------------------`


`id: SERIAL, PRIMARY KEY, NOT NULL` - used as the primary key for users

`username: varchar, NOT NULL` - The display name that Steam Buddy will use when sending a message

`steamid: varchar, NOT NULL` - the 64 bit steam id of a user

`steamvanity: varchar` - the vanity name of a user

`slackid: varchar` - This is the bot id of the slack bot integration this user is associated with

`integration_fk: varchar, FOREIGN KEY, NOT NULL` - This is the slack integration token that each user is associated with. If you are using the `sb_integration` table, this is a foreign key reference to it. This should also be set as unique with the steamid, if used.

The Postgres class in `lib/js/dao/` creates a connection string that is populated by environment variables. You must set all of these variables in order for Steam Buddy to connect to the database.

`PSQL_USERNAME` - The username of your PSQL user

`PSQL_PASS` - The password of your PSQL user

`PSQL_URL` - The url of your database (typically just `localhost`)

`PSQL_DB_NAME` - The name of your PSQL database

And that's it! That's all that the postgres instance requires for Steam Buddy to be fully functional.

## Configuring for Slack
In order for Steam Buddy to send Slack messages, it needs to be set up as a slack bot. Simply add a new bot integration to your slack team and set the channel(s) that you want Steam Buddy to run on. This is very simple. You can follow the instructions (here)[https://api.slack.com/bot-users] to add a new integration to your channel.

Once you have created the integration, there are then 2 ways you can tell Steam Buddy about the bot. If you are only going to run Steam Buddy within a single Slack team, you can set the slack token as an environment variable: `export SLACK_TOKEN="abcd-1234-abcd-1234"`. Steam Buddy will read this token in when launched and use it to authenticate into Slack and send messages.

The second way to save an integration is to store it within your database. If no `SLACK_TOKEN` environment variable is found, Steam Buddy will read in all the integrations from the `sb_integration` table of your configured database. `sb_integration` must have the following schema:

`                    id                     | type  | owner 
-------------------------------------------+-------+-------`

where id is your slack token (varchar), type is 'slack' (varchar), and owner is an integer. On start up, Steam Buddy will fetch all rows in this table and create new Slack integrations using the fetched tokens. This is useful for running Steam Buddy on multiple teams - each team's integration will have it's own token which is stored in the database.

Steam Buddy also requires a steam API key. You can generate an api key in steam, and then add it to your environment with `STEAM_API_KEY="ABCDEFGHIJKLMNOP1234567890"`.

## Running Steam Buddy
Running Steam Buddy requires that you have a few environment variables set:
* [Steam API Key](http://steamcommunity.com/dev/registerkey): set as environment variable `STEAM_API_KEY`
* [Slack Integration](https://api.slack.com/bot-users): set the slack token provided for the integration as `SLACK_TOKEN` (only needed if you do not have an `sb_integration` table in your database)

1. Clone the Steam Buddy repository.
2. Set up the configuration file (see Configuration section above)
3. Set up your integrations and environment variables (see Configuring for Slack above)
4. run `npm install` to install all dependencies
5. run `make run` to run steam buddy

It is suggested you run Steam Buddy as a daemon using something like screens or supervisord.

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
