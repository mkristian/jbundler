Bundler.require

org.slf4j.LoggerFactory.getLogger("hello").info <<-INFO
classpath:
#{JBUNDLER_CLASSPATH.join("\n")}
INFO
