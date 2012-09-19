require 'rubygems/commands/install_command'
require 'lock_jar'

class Gem::Commands::InstallCommand

  unless respond_to? :execute_without_jars
    alias :execute_without_jars :execute
    def execute
      begin
        execute_without_jars
      rescue Gem::SystemExitException => e
        if e.exit_code == 0
          puts "DO SOMETHING HERE WITH JARS [#{gems.join(',')}]"
        end
        raise e
      end
    end

    def gems
      @gems ||= []
    end

    alias :_s_a_y_ :say
    def say( arg )
      if arg =~ /^Successfully/
        arg.sub /([^ ]+$)/ do
          gems << $1
        end
      end
      _s_a_y_( arg )
    end
  end
end
