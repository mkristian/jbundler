if RUBY_PLATFORM =~ /java/
  class Java::JavaLang::Throwable
    def application_backtrace
      backtrace
    end
    def framework_backtrace
      backtrace
    end
    def clean_backtrace
      backtrace
    end
    def clean_message
      message
    end
    def blamed_files
      []
    end
  end
end
