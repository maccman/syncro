module Syncro
  module Protocol
    class MessageBuffer < StringIO
      def clear
        truncate(0)
      end
      
      # How much left to be read
      def left
        size - pos
      end
      
      def back(n)
        seek(n * -1, IO::SEEK_CUR)
      end
      
      def trim
        string.replace(read)
      end
      
      def messages
        messages = []
        rewind
        while !eof?
          break unless left > 2
          len = read_I16
          msg = read(len)
          if !msg || msg.length != len
            back(2 + msg.length)
            break
          end
          messages << msg
        end
        trim
        wind
        messages
      end
      
      def wind
        seek(0, IO::SEEK_END)
      end
      
      private      
        def read_I16
          dat = read(2)
          len, = dat.unpack('n')
          if (len > 0x7fff)
            len = 0 - ((len - 1) ^ 0xffff)
          end
          len
        end
    end
  end
end
