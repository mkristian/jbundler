if defined? JBUNDLER_CLASSPATH
  org.slf4j.LoggerFactory.getLogger("jbundler").info <<-INFO
classloader setup:
#{JBUNDLER_CLASSPATH.join("\n")}
INFO
else
  org.slf4j.LoggerFactory.getLogger("jbundler").info "NO setup !"
end
