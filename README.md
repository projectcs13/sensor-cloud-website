# IoT-Framework GUI

The IoT-Framework is a computation engine for the Internet of Things (IoT). It was developed jointly by Ericsson Research, the Swedish Institute of Computer Science (SICS) and Uppsala University in the scope of Project CS 2013. This repository contains the website (or GUI) for the IoT-Framework. In order to use it, you will also need the [IoT-Framework-engine](https://github.com/EricssonResearch/iot-framework-engine)

## Demo

You can check out a demo of the IoT-Framework here: [IoT-Framework
demo](https://vimeo.com/98966770). 

## Requirements

* Linux
* Ruby 1.9.3 (Ruby 2.0 preferred) [To install Ruby 2.0.0-p247 on Ubuntu 12.04 LTS you may want to consider these steps: http://stackoverflow.com/questions/9056008/installed-ruby-1-9-3-with-rvm-but-command-line-doesnt-show-ruby-v/9056395#9056395]

## Installation

1. You need to set an option for your shell in order for all of the software to work. Run 

        make help

and read the 'Important' section and follow the instructions.

2. Download and compile the dependencies, and compile the project sources
 
        make install

3. Run the application
 
        make run

## Usage

### In development mode

1. Install the gems needed:

        bundle install --without production

2. Migrate the database:

        bundle exec rake db:migrate
        
3. Download and start the IoT-Framework API hosted here: https://github.com/projectcs13/sensor-cloud

4. Modify the API_URL variable declared in the config/config.yml file to reflect the hostname/port of the API (by default the API uses port 8000):

        API_URL: "<Put your base URL here>:<put your port here>" 

5. Start the Rails server:

        rails s

### In production mode

1. Install the gems needed:

        bundle install

2. Migrate the database:

        RAILS_ENV=production bundle exec rake db:migrate

3. Precompile Rails assets:

        RAILS_ENV=production bundle exec rake assets:precompile

4. Modify the `config/config.yml` file according to your needs.

5. Open the script called `sensor_cloud` located in the sensor-cloud-website root folder, and modify the `USER` and `RAILS_ROOT` variables in accordance to your system settings.

6. Run:

        sudo cp sensor_cloud /etc/init.d/
        sudo chmod +x /etc/init.d/sensor_cloud
        sudo update-rc.d sensor_cloud defaults

Next time you reboot your computer, the Rails server should be running and the website accessible at `http://localhost:3000` (it may take a couple of seconds for the server to start after rebooting).

## Running tests

1. Run the tests
 
        make test

## More information

You can take a look at the wiki [here] (https://github.com/projectcs13/sensor-cloud-website/wiki).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Code Status

[![Build Status](https://travis-ci.org/projectcs13/sensor-cloud-website.png)](https://travis-ci.org/projectcs13/sensor-cloud-website)

## Licence

IoT-Framework is released under the [Apache License] (http://opensource.org/licenses/Apache-2.0).
