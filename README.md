# Steam Buddy

## About
Steam buddy is a small node bot that watches for Steam users to join a game. When a member starts playing a game, Steam Buddy sends a FastChat to the specified group notifying all group members that there friend has begun playing a game!

## Todo
1. Integrate fastchat login for steam_buddy so that the app can ensure a valid session token
2. Break out some of the constants that are stored in plaintext
3. Clean up and modularize the code


## Future features
1. Allow users to open the steam game from FastChat Web
2. Allow easy addition of new steam users to watch
3. Allow easy configuration of steam users, steam games, and FastChat groups
4. Upgrade to node 1.0.x (when FastChat upgrades)