require_relative "helper"
require "datadog/statsd"

class TestTCPServer < Minitest::Test

  def test_tcp_server
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
  end

end
