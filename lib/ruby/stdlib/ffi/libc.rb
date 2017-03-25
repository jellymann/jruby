# Originally from https://github.com/postmodern/ffi-libc

module FFI
  module LibC
    extend FFI::Library

    typedef :pointer, :FILE
    typedef :uint32, :in_addr_t
    typedef :uint16, :in_port_t

    # time.h
    typedef :long, :clock_t

    ffi_lib FFI::Library::LIBC

    # The NULL constant
    NULL = nil

    # errno.h
    unless FFI::Platform.windows?
      attach_variable :sys_errlist, :pointer
      attach_variable :sys_nerr, :int
      attach_variable :errno, :int
    end

    def self.raise_error(error=self.errno)
      raise(strerror(error))
    end

    # unistd.h
    unless FFI::Platform.windows?
      attach_function :brk, [:pointer], :int
      attach_function :sbrk, [:pointer], :pointer
      attach_function :getpid, [], :pid_t
      attach_function :getppid, [], :pid_t
      attach_function :getuid, [], :uid_t
      attach_function :geteuid, [], :uid_t
      attach_function :getgid, [], :gid_t
      attach_function :getegid, [], :gid_t
      attach_function :alarm, [:uint], :uint
    end

    # stdlib.h
    attach_function :calloc, [:size_t, :size_t], :pointer
    attach_function :malloc, [:size_t], :pointer
    FREE = attach_function :free, [:pointer], :void
    attach_function :realloc, [:pointer, :size_t], :pointer
    attach_function :getenv, [:string], :string
    unless FFI::Platform.windows?
      attach_function :putenv, [:string], :int
      attach_function :unsetenv, [:string], :int
    end

    unless FFI::Platform.windows?
      begin
        attach_function :clearenv, [], :int
      rescue FFI::NotFoundError
        # clearenv is not available on OSX
      end
    end

    # time.h
    attach_function :clock, [], :clock_t
    attach_function :time, [:pointer], :time_t

    # sys/time.h
    unless FFI::Platform.windows?
      attach_function :gettimeofday, [:pointer, :pointer], :int
      attach_function :settimeofday, [:pointer, :pointer], :int
    end

    # sys/mman.h
    unless FFI::Platform.windows?
      attach_function :mmap, [:pointer, :size_t, :int, :int, :int, :off_t], :pointer
      attach_function :munmap, [:pointer, :size_t], :int
    end

    # string.h
    attach_function :bzero, [:pointer, :size_t], :void unless FFI::Platform.windows?
    attach_function :memset, [:pointer, :int, :size_t], :pointer
    attach_function :memcpy, [:buffer_out, :buffer_in, :size_t], :pointer
    attach_function :memcmp, [:buffer_in, :buffer_in, :size_t], :int
    attach_function :memchr, [:buffer_in, :int, :size_t], :pointer

    unless FFI::Platform.windows?
      begin
        attach_function :memrchr, [:buffer_in, :int, :size_t], :pointer
      rescue FFI::NotFoundError
        # memrchr is not available on OSX
      end
    end

    attach_function :strcpy, [:buffer_out, :string], :pointer
    attach_function :strncpy, [:buffer_out, :string, :size_t], :pointer
    attach_function :strcmp, [:buffer_in, :buffer_in], :int
    attach_function :strncmp, [:buffer_in, :buffer_in, :size_t], :int
    attach_function :strlen, [:buffer_in], :size_t
    unless FFI::Platform.windows?
      attach_function :index, [:buffer_in, :int], :pointer
      attach_function :rindex, [:buffer_in, :int], :pointer
    end
    attach_function :strchr, [:buffer_in, :int], :pointer
    attach_function :strrchr, [:buffer_in, :int], :pointer
    attach_function :strstr, [:buffer_in, :string], :pointer
    attach_function :strerror, [:int], :string

    unless FFI::Platform.windows?
      begin
        attach_variable :stdin, :pointer
        attach_variable :stdout, :pointer
        attach_variable :stderr, :pointer
      rescue FFI::NotFoundError
        # stdin, stdout, stderr are not available on OSX
      end
    end

    attach_function :fopen, [:string, :string], :FILE
    attach_function :fdopen, [:int, :string], :FILE unless FFI::Platform.windows?
    attach_function :freopen, [:string, :string, :FILE], :FILE
    attach_function :fseek, [:FILE, :long, :int], :int
    attach_function :ftell, [:FILE], :long
    attach_function :rewind, [:FILE], :void
    attach_function :fread, [:buffer_out, :size_t, :size_t, :FILE], :size_t
    attach_function :fwrite, [:buffer_in, :size_t, :size_t, :FILE], :size_t
    attach_function :fgetc, [:FILE], :int
    attach_function :fgets, [:buffer_out, :int, :FILE], :pointer
    attach_function :fputc, [:int, :FILE], :int
    attach_function :fputs, [:buffer_in, :FILE], :int
    attach_function :fflush, [:FILE], :int
    attach_function :fclose, [:FILE], :int
    attach_function :clearerr, [:FILE], :void
    attach_function :feof, [:FILE], :int
    attach_function :ferror, [:FILE], :int
    attach_function :fileno, [:FILE], :int unless FFI::Platform.windows?
    attach_function :perror, [:string], :void

    attach_function :getc, [:FILE], :int
    attach_function :getchar, [], :int
    attach_function :gets, [:buffer_out], :int
    attach_function :ungetc, [:int, :pointer], :int

    attach_function :putc, [:int, :FILE], :int
    attach_function :putchar, [:int], :int
    attach_function :puts, [:string], :int

    # netdb.h
    unless FFI::Platform.windows?
      attach_function :getnameinfo, [
        :pointer,
        :socklen_t, :pointer,
        :socklen_t, :pointer,
        :socklen_t, :int
      ], :int
    end

    NI_MAXHOST = 1024
    NI_MAXSERV = 32

    NI_NUMERICHOST = 1       # Don't try to look up hostname.
    NI_NUMERICSERV = 2       # Don't convert port number to name.
    NI_NOFQDN      = 4       # Only return nodename portion.
    NI_NAMEREQD    = 8       # Don't return numeric addresses.
    NI_DGRAM       = 16      # Look up UDP service rather than TCP.

    # ifaddrs.h
    unless FFI::Platform.windows?
      attach_function :getifaddrs, [:pointer], :int
      attach_function :freeifaddrs, [:pointer], :void
    end

    #
    # Enumerates over the Interface Addresses.
    #
    # @yield [ifaddr]
    #   The given block will be passed each Interface Address.
    #
    # @yieldparam [Ifaddrs] ifaddr
    #   An Interface Address.
    #
    # @return [Enumerator]
    #   If no block is given, an enumerator will be returned.
    #
    # @since 0.1.0
    #
    def self.each_ifaddr
      return enum_for(__method__) unless block_given?

      ptr = MemoryPointer.new(:pointer)

      if getifaddrs(ptr) == -1
        raise_error
      end

      if (ifaddrs = ptr.get_pointer(0)).null?
        return
      end

      ifaddr = Ifaddrs.new(ifaddrs)

      while ifaddr
        yield ifaddr

        ifaddr = ifaddr.next
      end

      freeifaddrs(ifaddrs)
    end

    # bits/resource.h (Linux) / sys/resource.h (Darwin)
    RUSAGE_SELF = 0
    RUSAGE_CHILDREN = -1
    RUSAGE_THREAD = 1 # Linux/glibc only

    attach_function :getrusage, [:int, :pointer], :int unless FFI::Platform.windows?

    #
    # Gets the RUsage for the user.
    #
    # @param [RUSAGE_SELF, RUSAGE_CHILDREN, RUSAGE_THREAD] who
    #   Whome to get RUsage statistics for.
    #
    # @return [RUsage]
    #   The RUsage statistics.
    #
    # @raise [RuntimeError]
    #   An error has occurred.
    #
    # @since 0.1.0
    #
    def self.rusage(who=RUSAGE_SELF)
      rusage = RUsage.new

      unless (ret = getrusage(who,rusage)) == 0
        raise_error(ret)
      end

      return rusage
    end
  end
end
