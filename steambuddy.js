var request = require('request');
var http = require('http');
var Parser = require('./parser.js');

var parser = new Parser();

var hostUrl = 'http://powerful-cliffs-9562.herokuapp.com';
var hostPort = '80';
var hostPath = hostUrl + ':' + hostPort;
var usersToCheck = ['76561198024956371'/*ethan*/, '76561198081408345'/*me*/, '76561198013610944' /*jared*/, '76561198009215427' /*dave*/];
var currOnline = [];

var sessionToken = '7de545895cab3458527d079a6b3627e79f8898bfaa3dbc9898b78ff6e5077444d88e6ff9c9182262b4a2f6cdeb1a4d53' // steam_buddy session token
var io = require('socket.io-client');

var minutes = .1, the_interval = minutes * 60 * 1000; //60 seconds
setInterval(function() {
  for( var i = 0; i < usersToCheck.length; i++ ) {
    var steamId = usersToCheck[i];
    sendMessage(this.socket, steamId);
  }
}.bind(this), the_interval);

this.connect = function(token) {
  this.socket.on('connect', function() {
    console.log('Connected!');
  });

  this.socket.on('error', function(err) {
    console.log('error:', err);
  });

  this.socket.on('event', function(data) {
    console.log('event:', data);
  });
};



this.login = function() {
  var url = hostPath + '/login';
  console.log('url:',url);
  // MUST RUN WITH: $ STEAM_BUDDY_PASSWORD=<password> node steambuddy.js
  var password = process.env.STEAM_BUDDY_PASSWORD;
  var params = {'username':'steam_buddy', 'password':password};
  console.log('using password:',password);
  request.post({
    headers: {'content-type':'application/json'},
    uri: url,
    json: params
  }, function(error, response, body) {
       console.log('body', body['session-token']);
       var session_token = body['session-token'];
       if( session_token ) {
         this.socket = io.connect(hostPath, {query: "token="+session_token});

         this.socket.on('message', function(data) {
           console.log('message:', data);
           if( data.text.indexOf('@steam_buddy -a') > -1) {
             var arr = data.text.split(' ');
             var idIndex = arr.indexOf('-a') + 1;
             if( arr[idIndex] ) {
               var newUserId = arr[arr.indexOf('-a') + 1];
               var steamId = null;
//               try {
               if( isNaN(newUserId) ) {
                 addUser(newUserId, function(err, result) {
                   if (!err) {
                     usersToCheck.push(result);
                   }
                 });
               }
               else{
                 usersToCheck.push(newUserId);
               } 
             }
           }
         });

         this.setupSocket(this.socket);
       }
  }.bind(this));

//  this.connect(sessionToken);
//  this.socket = io.connect(hostPath, { query: "token="+sessionToken});
};


this.setupSocket = function(socket) {

};

this.login();

/*
 API Key: 9186ADF14E6553A2257FAC4856F822EA
 Castiel id: 76561198064286306
*/

var API_KEY = '9186ADF14E6553A2257FAC4856F822EA';
var TEST_ID = '76561198081408345'//ethan: '76561198024956371'; // me: '76561198081408345';//'76561198064286306';
var TEST_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9186ADF14E6553A2257FAC4856F822EA&steamids=';



var addUser = function(vanityName, callback) {
  request('http://steamcommunity.com/id/' + vanityName + '/?xml=1', function(error, response, body) {
    parser.parse(body, function(err, result) {
      console.log('MY RESULT', result);
//      callback(err, result);
      usersToCheck.push(result);
    });
  });
}

//var test = addUser('k0su');
//console.log('should push:', test);

var sendMessage = function(socket, steamIdToCheck) {
  var url = TEST_URL + steamIdToCheck;
  console.log('id to check:', steamIdToCheck);
  request(url, function (error, response, body) {
    if (!error && response.statusCode == 200) {
      var parsedResult = JSON.parse(body);
      var player = parsedResult.response.players[0];
      if (!player) return;
      var playerId = player.steamid;
      var playerName = player.personaname;
      var game = player.gameextrainfo;

      if( game ) {
	console.log('%s is playing %s',playerName,game);
	if (socket != null && !userIsInGame(playerId)) {
	  var groupId = '5341d9c9118f86020000000a';// test group: "5446efc342718e0200b33be1"; //Besties: 5341d9c9118f86020000000a
          var messageText = playerName + ' is playing ' + game + '! Go join him!';
          var message = {group: groupId, hasMedia: false, 'text': messageText};
	  notify(message, socket);
	  currOnline.push(playerId);
	}
	else {
	  console.log('not connected');
	}
      }
      else {
	if (userIsInGame(playerId)) {
	  console.log('remove from game');
	  currOnline.splice(currOnline.indexOf(playerId), 1);
	}

      }
    }
  });
}

var userIsInGame = function(playerId) {
  return currOnline.indexOf(playerId) >= 0;
}

var notify = function(message, socket) {
  console.log('notifying', message);
  socket.emit('message', message);
}
