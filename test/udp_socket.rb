require_relative "helper"
require "datadog/statsd"

class TestBasics < Minitest::Test

  def test_udp_socket
    x = PhonyBaloney::Server::UDP.new(port: 8126)
    x.run do |input|
      ds = Datadog::Statsd.new('localhost', 8126)
      ds.increment("some.metric")
      assert_equal "some.metric:1|c", input.nextline
    end
  end

end
