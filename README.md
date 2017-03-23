# LitmusPaper

Backend health tester for HA Services, or as an agent-check for HAProxy

[![Build Status](https://secure.travis-ci.org/braintree/litmus_paper.png)](http://travis-ci.org/braintree/litmus_paper)

## Installation

Add this line to your application's Gemfile:

    gem 'litmus_paper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install litmus_paper

## Usage

Use the sample config to run it under unicorn. Or when running it as an
agent-check for HAProxy use the sample xinetd config.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
