#
# Copyright (C) 2013 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'java'
require 'pathname'
require 'jbundler/aether'

module JBundler
  class AdhocLoader
    class << self

      # Wrap this method around the require statements in the root of your project that
      # need the jarfile to be loaded. If the program has not been started in the correct
      # jbundler context, it will still try to load the current library's Jarfile.
      #
      # Example:
      #
      #   JBundler::AdhocLoader.with_jarfile do
      #     require 'pacer/loader'
      #   end
      #
      def with_jarfile(jarfile = nil)
        begin
          yield
        rescue NameError
          STDERR.puts "WARNING: Using AdhocLoader to get requried jars. Jar loading is more reliable if you run in a correctly jbundled context."
          jarfile = find_jarfile(caller, jarfile)
          if jarfile
            loader = JarLoader.new
            loader.instance_eval jarfile.read
            loader.jars.each { |path| require path }
            yield
          else
            throw
          end
        end
      end

      private

      def find_jarfile(callers, jarfile)
        jarfile = Pathname.new jarfile if jarfile
        if jarfile and jarfile.exist?
          jarfile
        else
          calling_file = callers.first.split(':', 2).first
          dir = Pathname.new(calling_file).dirname
          while not (dir + 'Jarfile').exist?
            if dir.to_s == '.' or dir.to_s == '/'
              STDERR.puts "Unable to find Jarfile for #{ calling_file }"
              return nil
            end
            dir = dir.dirname
          end
          jarfile = dir + 'Jarfile'
        end
      end
    end

    def jars
      aether.classpath_array
    end

    def jar(name, version, opts = {})
      aether.add_artifact("#{name}:#{version}")
      aether.resolve
    end

    private

    def aether
      @_aether ||= AetherRuby.new
    end
  end
