parseString = require('xml2js').parseString

class Parser
  parse: (xml, callback)->
    userId = null;
    parseString(xml, (err, result)->
      if( result && result.profile )
        steamId64Bit = result.profile.steamID64[0]
        steamID = result.profile.steamID[0]
        if( !err )
          callback(null, {name: steamID, id: steamId64Bit})
    )

module.exports = Parser
