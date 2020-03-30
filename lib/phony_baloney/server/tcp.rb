require 'socket'

module PhonyBaloney
  module Server
    class TCP

      def initialize(host: '127.0.0.1', port:)
        @host = host
        @port = port
        @buf = Buffer.new
        @stopping = false
      end

      def run
        @socket = TCPServer.new(@host, @port)
        @t = Thread.new(&method(:handler))

        begin
          yield @buf
        ensure
          stop
        end if block_given?
      end

      def handler
        Thread.current.report_on_exception = true
        client = @socket.accept
        begin

          msg = ""
          loop do
            return if @stopping

            rc = client.recv_nonblock(16384, 0, nil, exception: false)
            if rc == :wait_readable
              @buf << msg if msg != ""
              msg = ""
              IO.select([@socket])
            else
              if rc.bytesize == 16384
                msg += rc
              else
                @buf << msg if msg != ""
                @buf << rc
                msg = ""
              end
            end
          end

        rescue Errno::EBADF
          raise if !@stopping
        rescue IOError
          raise if !@stopping
        ensure
          client.close
        end
      end
      private :handler

      def stop
        @stopping = true
        @socket.close
        @buf.close
        true
      end

    end
  end
end

