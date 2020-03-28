# phony

## Purpose

Do you have a network client that needs testing? I had some statsd
metrics code I needed to test but I didn't want to start/stop a full Statsd server
within my test suite. This gem aims to make it simple to run a server
which can replay a set of replies and assert the expected network chatter.

## TODO

* Low-level support
  * [ ] TCP
  * [ ] UDP
  * [ ] Unix socket
* High-level support
  * Other gems solve this, e.g. vcr, not a priority

## API

```ruby
require 'phony'
require 'datadog/statsd'

x = Phony::Server::UDP.new(port: 8125)
x.run # kicks off a separate thread

ds = Datadog::Statsd.new('localhost', 8125)

# this is UDP so there's no response
x.expect("some.metric:1|c") do
  ds.increment("some.metric")
  # implicitly verifies the expectation at the end of the block
end
```

## Installation

Put this in your Gemfile:

```
gem 'phony', group: :test
```
