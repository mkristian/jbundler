module JBundler
  module MavenUtil
    
    def to_coordinate(line)
      if line =~ /^\s*(jar|pom)\s/
        
        group_id, artifact_id, version, second_version = line.sub(/\s*[a-z]+\s+/, '').sub(/#.*/,'').gsub(/\s+/,'').gsub(/['"],/, ':').gsub(/['"]/, '').split(/:/)
        mversion = second_version ? to_version(version, second_version) : to_version(version)
        extension = line.strip.sub(/\s+.*/, '')
        "#{group_id}:#{artifact_id}:#{extension}:#{mversion}"
      end
    end

    def to_version(*args)
      if args.size == 0 || (args.size == 1 && args[0].nil?)
        "[0,)"
      else
        low, high = convert(args[0])
        low, high = convert(args[1], low, high) if args[1] =~ /[=~><]/
        if low == high
          low
        else
          "#{low || '[0'},#{high || ')'}"
        end
      end
    end
    
    private

    def convert(arg, low = nil, high = nil)
      if arg =~ /~>/
        val = arg.sub(/~>\s*/, '')
        last = val.sub(/\.[^.]+$/, '.99999')
        ["[#{val}", "#{last}]"]
      elsif arg =~ />=/
        val = arg.sub(/>=\s*/, '')
        ["[#{val}", (nil || high)]
      elsif arg =~ /<=/
        val = arg.sub(/<=\s*/, '')
        [(nil || low), "#{val}]"]
        # treat '!' the same way as '>' since maven can not describe such range
      elsif arg =~ /[!>]/  
        val = arg.sub(/[!>]\s*/, '')
        ["(#{val}", (nil || high)]
      elsif arg =~ /</
        val = arg.sub(/<\s*/, '')
        [(nil || low), "#{val})"]
      elsif arg =~ /\=/
        val = arg.sub(/=\s*/, '')
        ["[" + val, val + '.0.0.0.0.1)']
      else
        [arg, arg]
      end
    end
  end
end
