var request = require('request');

var hostUrl = 'http://powerful-cliffs-9562.herokuapp.com';
var hostPort = '80';
//var hostPath = hostUrl + ':' + hostPort;
var hostPath = '127.0.0.1:3000';
//var sessionToken = 'ba716392dca54875977ef32f11a41165174f0dd61c13a79a2ec7bf59dd44509387b2dc8c1ab127ca79e250153f08cb52';
var sessionToken = '4a758c0306e81c61f04f8cb367f602ef42bdad20860727a20fe6d417a858a45e51e53ff087b9e782e1791b60727c74e2'
var io = require('socket.io-client');
this.socket = null;

this.connect = function(token) {
  console.log('Connecting to Socket.io!');
  this.socket = io.connect(hostPath, { query: "token="+token });
  console.log('set socket',this.socket);
  this.socket.on('connect', function() {
    console.log('Connected!');
    sendMessage(this.socket);
  });

  this.socket.on('error', function(err) {
    console.log('error:', err);
  });

  this.socket.on('event', function(data) {
    console.log('event:', data);
  });
};

this.connect(sessionToken);


/*
 API Key: 9186ADF14E6553A2257FAC4856F822EA
 Castiel id: 76561198064286306
*/

var API_KEY = '9186ADF14E6553A2257FAC4856F822EA';
var TEST_ID = '76561198081408345'//ethan: '76561198024956371'; // me: '76561198081408345';//'76561198064286306';
var TEST_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9186ADF14E6553A2257FAC4856F822EA&steamids='+TEST_ID;
var sendMessage = function(socket) {
  request(TEST_URL, function (error, response, body) {
    if (!error && response.statusCode == 200) {
      var parsedResult = JSON.parse(body);
      var player = parsedResult.response.players[0];
      var playerName = player.personaname;
      var game = player.gameextrainfo;
      console.log('%s is playing %s',playerName,game);
      console.log('socket:',this.socket);
      if( game ) {
	if( socket != null ) {
          var messageText = playerName + ' is playing ' + game + '! Go join him!';
          var message = {from: '5442e50b36f60d020079e358', group: '5341d9c9118f86020000000a', hasMedia: false, sent: Date.now(), 'text': messageText};
	  notify(message, socket);
	}
	else {
	  console.log('not connected');
	}
      }
    }
  });
}

var notify = function(message, socket) {
  console.log('notifying', message);
  socket.emit('message', message);
}
