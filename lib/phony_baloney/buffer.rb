require 'thread'
require 'stringio'

module PhonyBaloney
  class Buffer

    def initialize
      @data = String.new
      @mu = Mutex.new
      @cond = ConditionVariable.new
      @closed = false
    end

    def close
      @closed = true
    end

    def <<(bytes)
      @mu.synchronize do
        @data << bytes
        @cond.signal
      end
      nil
    end

    def read(count)
      raise "phony buffer closed" if @closed

      @mu.synchronize do
        loop do
          if @data.size > 0
            rc = @data.slice!(0, count)
            return rc
          end
          @cond.wait(@mu)
        end
      end
      nil
    end

    def gets
      raise "phony buffer closed" if @closed

      @mu.synchronize do
        line = ""
        loop do
          if @data.size > 0
            idx = @data.index("\n")
            if idx
              line += @data.slice!(0, idx+1)
              return line
            else
              line += @data
              @data = ""
            end
          end
          @cond.wait(@mu)
        end
      end
      nil
    end

    def size
      @data.size
    end
  end
end
