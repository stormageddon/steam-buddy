parseString = require('xml2js').parseString

class Parser
  parse: (xml, callback)->
    userId = null;
    parseString(xml, (err, result)->
      console.log 'result:', result
      if( result && result.profile )
        steamId64Bit = result.profile.steamID64[0]
        steamID = result.profile.steamID[0]
        console.log 'id: ', steamId64Bit
        if( !err )
          console.log 'returning'
          callback(null, {name: steamID, id: steamId64Bit})
    )

module.exports = Parser
