module JBundler
  module MavenVersion

    def convert_version(*args)
      if args.size == 0
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
        val = arg.sub(/>\s*/, '')
        ["(#{val}", (nil || high)]
      elsif arg =~ /</
        val = arg.sub(/<\s*/, '')
        [(nil || low), "#{val})"]
      elsif arg =~ /\=/
        val = arg.sub(/=\s*/, '')
        [val, val]
      else
        [arg, arg]
      end
    end
  end
end
