# phony_baloney

## Purpose

Do you have a network client that needs testing? I had some statsd
metrics code I needed to test but I didn't want to start/stop a full Statsd server
within my test suite. This gem aims to make it simple to run a server
which can replay a set of replies and assert the expected network chatter.

## TODO

* Low-level support
  * [x] TCP
  * [x] UDP
  * [ ] Unix socket
* Considerations
  * [ ] Smoother API for sending and asserting request/replies?
* High-level support
  * Other gems solve this, e.g. vcr, not a priority

## HELP WANTED

This gem is brand new and needs more features and a cleaner, more
idiomatic Ruby API.  Contributors and contributions very, very welcome!
Open an issue or send a PR.

## API

```ruby
require 'phony_baloney'
require 'datadog/statsd'

#
#  UDP Server example
#

x = PhonyBaloney::Server::UDP.new(port: 8126)
x.run do |input|
  ds = Datadog::Statsd.new('localhost', 8126)
  ds.increment("some.metric")
  assert_equal "some.metric:1|c", input.read(20)
end

#
#  TCP Server example
#

x = PhonyBaloney::Server::TCP.new(port: 8126)
x.run do |buf|
  large = "bbbbbbbbbbbbbbbbbbbbbbbb" * 1024
  large += "\n"

  cl = TCPSocket.new("localhost", 8126)
  cl << "aaa\n"
  cl << large
  cl << "ccccc"

  assert_equal "aaa\n", buf.gets
  assert_equal large, buf.gets
  assert_equal "ccccc", buf.read(6)

  cl.close
end
```

READMEs can get out of date, see the test suite for real code.

## Installation

Put this in your Gemfile:

```
gem 'phony_baloney', github: 'mperham/phony_baloney', group: :test
```
