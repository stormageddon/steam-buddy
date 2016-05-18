'use strict'

pg = require('pg')
Q = require('q')

class Postgresql
  username = process.env.PSQL_USERNAME
  password = process.env.PSQL_PASS
  url = process.env.PSQL_URL
  dbName = process.env.PSQL_DB_NAME
  connectionString = "postgres://#{username}:#{password}@#{url}/#{dbName}";
  client = null

  constructor: ->

    console.log 'constructing psql connection', connectionString

    client = new pg.Client(connectionString)
    client.connect()

  insertUser: (username, accountName, steamid, slackid)->
    deferred = Q.defer()
    insertStr = "INSERT INTO sb_user(username, steamvanity, steamid, slackid) values('#{username}', '#{accountName}', '#{steamid}', '#{slackid}')";
    client.query insertStr, (err, client, done)=>
      return deferred.reject(error: 'failed to save user: ' + err) if err
      deferred.resolve(message: username + ' saved successfully')

    deferred.promise

  getUsersForSystem: (system)->
    deferred = Q.defer()
    selectStr = ''
    if system is 'steam'
      selectStr = "SELECT * FROM sb_user WHERE steamid is not null;"
    client.query selectStr, (err, result)=>
      return deferred.reject(error: "error fetching #{system} users") if err
      deferred.resolve(users: result.rows)
    deferred.promise

  deleteUser: (col, id)->
    deferred = Q.defer()
    console.log 'delete user from db'
    deleteStr = "DELETE FROM ONLY sb_user WHERE #{col}='#{id}';"
    client.query deleteStr, (err, result)=>
      return deferred.reject(error: "error deleting #{id} from db") if err
      deferred.resolve(message: "Successfully deleted #{id} from db")
    deferred.promise


  module.exports = Postgresql
