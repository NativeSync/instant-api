# Native API

Native API is a JSON-configured REST API written in Santra. It's extremely lightweight. The target market is people who want to generate a SIMPLE REST API straight from their database with no code required. Just supply a connection configuration file and you're off.

Native API is a work in progress - star the repo and check back soon.

The creators of native API believe that all database objects should be queryable on `create timestamp` and `update timestamp` fields, which allows for an internet-wide object sync process.

###Key features:
* Supports DB-instance-per-user, DB-server-per-user, and client ID data partitioning strategies
* Supports most SQL DBs (refer to Sequel ruby gem for supported databases)
* JSON-configured, no coding required
* Auth data stored in Redis
* Automatically integrates with [NativeSync](http://nativesync.io) for access to an entire community of integrations

###Upcoming features
* NoSQL database support
* Support for joins
* Many examples
* A web UI to develop your NativeAPI
* Instructions for integrating with NativeSync.

## Installation

`git clone && bundle install && rackup config.ru`

## Configuration

API config is stored in `config/api_config.json`

Requires a DB connection string and a list of database tables you wish to expose. Examples are in the `examples` directory, with more full examples to come soon.

## Consulting

Since NativeAPI is still a work in progress, NativeSync is available to help partners use the API. Drop us a line.

## Contact

Contact nick@nativesync.io for questions and comments.

