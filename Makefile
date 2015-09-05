compile:
	./node_modules/coffee-script/bin/coffee --compile --output dist/ lib/

run:
	$(MAKE) compile
	PLAYER_SUMMARY_URL='http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9186ADF14E6553A2257FAC4856F822EA&steamids=' \
	node ./dist/js/steambuddy.js
