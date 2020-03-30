require 'socket'

module PhonyBaloney
  module Server
    class UDP

      def initialize(host: '127.0.0.1', port:)
        @host = host
        @port = port
        @buf = Buffer.new
        @stopping = false
      end

      def run
        @socket = UDPSocket.new
        @socket.bind(@host, @port)

        @t = Thread.new do
          Thread.current.report_on_exception = true
          begin
            loop do
              return if @stopping
              rc = @socket.recvfrom_nonblock(16384, 0, nil, exception: false)
              if rc == :wait_readable
                IO.select([@socket])
              else
                @buf << rc[0]
              end
            end
          rescue Errno::EBADF
            raise if !@stopping
          rescue IOError
            raise if !@stopping
          end
        end

        begin
          yield @buf
        ensure
          stop
        end if block_given?
      end

      def stop
        @stopping = true
        @socket.close
        @buf.close
        true
      end

    end
  end
end
