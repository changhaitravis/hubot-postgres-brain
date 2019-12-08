# Description:
#   Stores the brain in Postgres
#
# Dependencies:
#   "pg": "~0.10.2"
#
# Configuration:
#   DATABASE_URL
#   DATABASE_SSL
#   HUBOT_BRAIN_SAVE_INTERVAL
#
# Commands:
#   None
#
# Notes:
#   Run the following SQL to setup the table and column for storage.
#
#   CREATE TABLE hubot (
#     id CHARACTER VARYING(1024) NOT NULL,
#     storage JSONB,
#     CONSTRAINT hubot_pkey PRIMARY KEY (id)
#   )
#   INSERT INTO hubot VALUES(1, NULL)
#
# Original Source pg-brain.coffee (hubot-pg-brain)
# https://github.com/github/hubot-scripts/blob/master/src/scripts/pg-brain.coffee
# Original Author:
#   danthompson
# Modified for storage JSONB instead of storage TEXT By:
#   Travis Juntara

Postgres = require 'pg'

if(process.env.DATABASE_SSL){
    Postgres.defaults.ssl = true
}

# sets up hooks to persist the brain into postgres.
module.exports = (robot) ->

  database_url = process.env.DATABASE_URL
  save_interval = process.env.HUBOT_BRAIN_SAVE_INTERVAL || 15 * 60 #Default Every 15 Minutes

  if !database_url?
    throw new Error('pg-brain requires a DATABASE_URL to be set.')
    
  save_interval = parseInt(save_interval)
  if isNaN(save_interval)
    throw new Error('HUBOT_BRAIN_SAVE_INTERVAL must be an integer')

  client = new Postgres.Client(database_url)
  client.connect()
  robot.logger.debug "postgres-brain connected to #{database_url}."

  query = client.query("SELECT storage FROM hubot LIMIT 1")
  query.on 'row', (row) ->
    if row['storage']?
      robot.brain.mergeData row['storage']
      robot.logger.debug "pg-brain loaded."
      robot.brain.resetSaveInterval(save_interval)
      robot.logger.debug "robot.brain saveInterval set to #{save_interval}."

  client.on "error", (err) ->
    robot.logger.error err

  robot.brain.on 'save', (data) ->
    query = client.query("UPDATE hubot SET storage = $1", [data])
    robot.logger.debug "postgres-brain saved."

  robot.brain.on 'close', ->
    client.end()

