SCRIPT_LINES__ = {}

OBJECT_FILE_MAPPINGS = {}

OBJECT_REFERENCE_MAPPINGS = {}

module CustomRequire
  
  def require(*)
    starting_constants = Object.constants.sort.dup
    starting_filenames = $".dup
    
    super
    
    ending_constants = Object.constants.sort.dup
    ending_filenames = $".dup
    
    added_constants = (ending_constants-starting_constants).sort
    added_filenames = (ending_filenames-starting_filenames).sort
    
    added_filenames.each do |filename|
      OBJECT_FILE_MAPPINGS[filename] = [OBJECT_FILE_MAPPINGS[filename], added_constants].flatten.compact
    end
  
  end
  
end
Object.__send__ :include, CustomRequire

module Rreader
  class Reference
    attr_accessor :file, :line, :code
    
    def initialize(file, line, code)
      @file = file
      @line = line
      @code = code
    end
  end
  
  def self.read(&block)
    yield
        
    puts "Mapping Objects to Files/Lines in which they are referenced"
    OBJECT_FILE_MAPPINGS.each do |filename, constants|
      constants.flatten.uniq.each do |constant_name|
        SCRIPT_LINES__.each do |filepath, lines|
          next if filepath[filename]
          lines.each_with_index do |line, idx|
            if line[constant_name]
              reference = Rreader::Reference.new(filepath, idx+1, line)
            
              OBJECT_REFERENCE_MAPPINGS[constant_name] = [OBJECT_REFERENCE_MAPPINGS[constant_name], reference].flatten.compact.uniq
            end
          end
        end
      end
    end
  end
  
  def self.references
    OBJECT_REFERENCE_MAPPINGS.sort{ |a,b| b[1].size <=> a[1].size }
  end
  
end