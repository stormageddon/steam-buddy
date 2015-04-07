var parseString = require('xml2js').parseString;

function Parser() {

}

Parser.prototype.parse = function(xml, callback) {
  var userId = null;
  parseString(xml, function(err, result) {
    console.log('result:', result);
    if( result && result.profile ) {
      var steamId64Bit = result.profile.steamID64[0];
      console.log('id: ', steamId64Bit);
      if( !err ) {
        console.log('returning');
        callback(null, steamId64Bit);
      }
    }
  });
}

module.exports = Parser;