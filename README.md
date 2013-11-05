# Welcome to Sensor Cloud

## Requirements

* Linux
* Ruby 1.9.3 (Ruby 2.0 preferred) 

## Installation

1. You need to set an option for your shell in order for all of the software to work. Run 

        make help

and read the 'Important' section and follow the instructions.

2. Download and compile the dependencies, and compile the project sources
 
        make install

3. Run the application
 
        make run

## Usage

1. Install the gems needed:

        bundle install

2. Migrate the database:

        bundle exec rake db:migrate

3. Start the Rails server:

        rails s

## Running tests

1. Run the tests
 
        make test

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Code Status

[![Build Status](https://travis-ci.org/projectcs13/sensor-cloud-website.png)](https://travis-ci.org/projectcs13/sensor-cloud-website)

## Licence

Sensor Cloud is released under the [Apache License] (http://opensource.org/licenses/Apache-2.0).
