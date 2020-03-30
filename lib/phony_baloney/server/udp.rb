require 'socket'

module PhonyBaloney
  module Server
    class UDP

      class Receiver
        include Enumerable
        def initialize
          @data = []
          @mu = Mutex.new
          @cond = ConditionVariable.new
          @closed = false
        end

        def close
          @closed = true
        end

        def <<(data)
          @mu.synchronize do
            @data << data
            @cond.signal
          end
          nil
        end

        def nextline
          raise "phony socket closed" if @closed

          @mu.synchronize do
            loop do
              return @data.shift if @data.size > 0
              @cond.wait(@mu)
            end
          end
          nil
        end

        def each(&block)
          @data.each(&block)
        end

        def bytesize
          @data.sum(&:bytesize)
        end

        def size
          @data.size
        end
      end

      def initialize(host: '127.0.0.1', port:)
        @host = host
        @port = port
        @recv = Receiver.new
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
                @recv << rc[0]
              end
            end
          rescue Errno::EBADF
            raise if !@stopping
          rescue IOError
            raise if !@stopping
          end
        end

        begin
          yield @recv
        ensure
          stop
        end if block_given?
      end

      def stop
        @stopping = true
        @socket.close
        @recv.close
        true
      end

    end
  end
end
