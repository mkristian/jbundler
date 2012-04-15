require 'fileutils'
require 'tempfile'
require 'jbundler/maven_util'
require 'java'

module JBundler

  class Pom

    include MavenUtil

    private
    
    def temp_dir
      @temp_dir ||=
        begin
          d = Dir.mktmpdir
          at_exit { FileUtils.rm_rf(d.dup) }
          d
        end
    end
      
    def writeElement(xmlWriter,element_name, text)
      xmlWriter.writeStartElement(element_name.to_java)
      xmlWriter.writeCharacters(text.to_java)
      xmlWriter.writeEndElement        
    end
    
    def java_imports
      %w(
           javax.xml.stream.XMLStreamWriter
           javax.xml.stream.XMLOutputFactory
           javax.xml.stream.XMLStreamException
          ).each {|i| java_import i }
    end

    GROUP_ID = 'ruby.bundler'
    
    public
    
    def coordinate
      @coord ||= "#{GROUP_ID}:#{@name}:#{@packaging}:#{@version}"
    end
    
    def file
      @file
    end

    def initialize(name, version, deps, packaging = nil)
      unless defined? XMLOutputFactory
        java_imports
      end

      @name = name
      @packaging = packaging || 'jar'
      @version = version

      @file = File.join(temp_dir, 'pom.xml')

      out = java.io.BufferedOutputStream.new(java.io.FileOutputStream.new(@file.to_java))
      outputFactory = XMLOutputFactory.newFactory()
      xmlStreamWriter = outputFactory.createXMLStreamWriter(out)
      xmlStreamWriter.writeStartDocument
      xmlStreamWriter.writeStartElement("project")
      
      writeElement(xmlStreamWriter,"modelVersion","4.0.0")
      writeElement(xmlStreamWriter,"groupId", GROUP_ID)
      writeElement(xmlStreamWriter,"artifactId", name)
      writeElement(xmlStreamWriter,"version", version.to_s.to_java)
      writeElement(xmlStreamWriter,"packaging", packaging) if packaging
      
      xmlStreamWriter.writeStartElement("dependencies".to_java)
      
      deps.each do |line|
        if coord = to_coordinate(line)
          group_id, artifact_id, extension, version = coord.split(/:/)

          xmlStreamWriter.writeStartElement("dependency".to_java)
          writeElement(xmlStreamWriter,"groupId", group_id)
          writeElement(xmlStreamWriter,"artifactId", artifact_id)
          writeElement(xmlStreamWriter,"version", version)
          
          writeElement(xmlStreamWriter,"type", extension) if extension != 'jar'
          xmlStreamWriter.writeEndElement #dependency
        end
      end
      xmlStreamWriter.writeEndElement #dependencies
      
      xmlStreamWriter.writeEndElement #project
      
      xmlStreamWriter.writeEndDocument
      xmlStreamWriter.close
      out.close
    end
    
  end
end
