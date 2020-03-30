require_relative "helper"
require "datadog/statsd"

class TestUDPSocket < Minitest::Test

  def test_udp_socket
    x = PhonyBaloney::Server::UDP.new(port: 8126)
    x.run do |buf|
      ds = Datadog::Statsd.new('localhost', 8126)
      ds.increment("some.metric")
      assert_equal "some.metric:1|c", buf.read(16)
    end
  end

end
