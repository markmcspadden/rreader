puts "Welcome to the Ruby Reader"

SCRIPT_LINES__ = {}

OBJECT_FILE_MAPPINGS = {}

OBJECT_REFERENCE_MAPPINGS = {}

# Jacked from ActiveSupport...probably should just require AS at some point
module StringExtensions
  def underscore
    word = self.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end
String.__send__ :include, StringExtensions

# Again with the ActiveSupport stealing
module ArrayExtensions
  def uniq_by
    hash, array = {}, []
    each { |i| hash[yield(i)] ||= (array << i) }
    array
  end
end
Array.__send__ :include, ArrayExtensions

module CustomRequire
  
  def require(*args)
    puts "Using CustomRequire for #{args}"
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
    puts "Added constants: #{added_constants.join(",")}"
    puts "Added filenames: #{added_filenames}"
  
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
    
    def ==(other)
      self.file == other.file && self.line == other.line && self.code == other.code
    end
    def uniq_attrs
      [self.file, self.line, self.code]
    end
  end
  
  def self.read(&block)
    yield
       
    # REFACTOR: This is a big ugly block of code 
    # OPTIMIZE: This is a very brute way of doing this...
    puts "Mapping Objects to Files/Lines in which they are referenced"
    OBJECT_FILE_MAPPINGS.each do |filename, constants|
      puts "Mapping file #{filename}"
      constants.flatten.uniq.each do |constant_name|
        puts "Mapping constant #{constant_name}"
        SCRIPT_LINES__.each do |filepath, lines|
          puts "Looking for #{constant_name} in #{filepath}"
          next if filepath[filename]
          lines.each_with_index do |line, idx|
            puts "Analyzing line #{idx+1} of #{filepath} for #{constant_name}"
            if reference_match(constant_name, line)
              puts "Match for #{constant_name} found in line #{idx+1} of #{filepath}"
              reference = Rreader::Reference.new(filepath, idx+1, line)
            
              OBJECT_REFERENCE_MAPPINGS[constant_name] = [OBJECT_REFERENCE_MAPPINGS[constant_name], reference].flatten.compact.uniq_by{ |r| r.uniq_attrs }
            end
          end
        end
      end
    end
  end
  
  def self.read_rails(rails_root)
    Rreader.read do
      Dir.glob("#{rails_root}/app/models/*.rb").each do |filename|
        require filename
      end
    end
  end
  
  def self.reference_match(constant_string, line_string)
    match_regex = /(#{constant_string}|#{constant_string.underscore})/
    line_string[match_regex]
  end
  
  def self.references
    OBJECT_REFERENCE_MAPPINGS.sort{ |a,b| b[1].size <=> a[1].size }
  end
  
end