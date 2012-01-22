# EM Postgresql Sequel

## Installation

* gem install pg
* gem install eventmachine
* gem install sequel
* gem install em-postgesql-sequel

## Examples

### Run 3 fiber queries concurrently, utilizing 3 connections

    ['logger', 'pg', 'sequel', 'eventmachine', 'em-postgresql-sequel', 'fiber'].each do |lib| 
      require lib
    end

    EM::run do
      Fiber.new do
        DB = Sequel.connect 'postgres://user:pass@localhost:5432/db', :logger => Logger.new(STDOUT), :max_connections => 3, :pool_class => EM::Sequel::FiberedConnectionPool

        (1..10).each do |num|
          Fiber.new do
            res = DB["select 'f#{num}' as fiber, pg_sleep(3)"].all
            puts "f#{num} done, res: #{res.inspect}"
          end.resume
        end
      end.resume
    end

### Run 1 fiber query at a time, utilizing 1 connection

    ['logger', 'pg', 'sequel', 'eventmachine', 'em-postgresql-sequel', 'fiber'].each do |lib| 
      require lib
    end

    EM::run do
      Fiber.new do
        DB = Sequel.connect 'postgres://user:pass@localhost:5432/db', :logger => Logger.new(STDOUT), :max_connections => 1, :pool_class => EM::Sequel::FiberedConnectionPool

        (1..10).each do |num|
          Fiber.new do
            res = DB["select 'f#{num}' as fiber, pg_sleep(3)"].all
            puts "f#{num} done, res: #{res.inspect}"
          end.resume
        end
      end.resume
    end

## Known Issues

* disconnected connection

## Todos

* add some test cases