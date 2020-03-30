# phony_baloney

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
require 'phony_baloney'
require 'datadog/statsd'

x = PhonyBaloney::Server::UDP.new(port: 8126)
x.run do |input|
  ds = Datadog::Statsd.new('localhost', 8126)
  ds.increment("some.metric")
  assert_equal "some.metric:1|c", input.nextline
end
```

## Installation

Put this in your Gemfile:

```
gem 'phony_baloney', group: :test
```
