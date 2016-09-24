# hubot-postgres-brain
Hubot Brain persistence into Postgres

based on the original first pass script by Dan Thompson of Github(?) https://github.com/github/hubot-scripts/blob/master/src/scripts/pg-brain.coffee

## Setup

` CREATE TABLE hubot (
     id CHARACTER VARYING(1024) NOT NULL,
     storage JSON,
     CONSTRAINT hubot_pkey PRIMARY KEY (id)
   )
   INSERT INTO hubot VALUES(1, NULL)`

### Why Fork?
1. In the original script, TEXT datatype was used instead of JSON. This is potentially less space efficient, there is also no JSON validation (also offered by the JSON datatype along with JSONB). JSON, along with being space efficient and JSON validating, also indexes the JSON content, however, since we're plopping the entire hubot brain into 1 attribute of 1 row, the Index is meaningless. JSON and JSONB also take the work off of the dyno/web server from having to parse and stringify the javascript objects in the brain to from json.
2. Set a Save Interval. I've copied from the hubot-scripts/s3-brain. Basically saving the entire brain to a relational database could potentially be an intensive operation. The default save interval was every few seconds, and this is completely unnecessary/overkill. Override is in place with a default of 15 minutes.
3. The original script is not in the form of a node_module.

### Why Postgres? Why not Redis?
Redis seems like the official method of brain persistence. However, Postgres offers a few advantages:

1. Heroku offers Postgres as a free add-on. Although Redis is also free, it requires a credit card for "Validation". It seems, however, that the free dynos and Postgres Databases do not.
2. 1GB max size per TEXT/JSON field, even on the Heroku hobby-dev free tier. Whereas the Redis free-tier offers 25MB.
3. If you deploy it yourself, Redis actually takes extra steps during setup for its data store to survive a reboot (its key-value store is in memory just like hubot's robot brain)

