require 'test/unit'

# Require pretty print now so it does NOT get analyzed if a test fails
require 'pp'

class RreaderTest < Test::Unit::TestCase
  def setup
    # NOTE: This is late loaded as to not have test/unit requires overwritten by our custom requires    
    require '../lib/rreader'
    
    # Bla....gotta be a better way...
    OBJECT_REFERENCE_MAPPINGS.clear
    
    Rreader.read do
      require 'class_one'
      require 'class_two'
    end
  end
  
  
  def test_custom_require
    assert ClassOne
    assert ClassTwo    
  end
  
  def test_object_file_mappings    
    assert_equal ["class_one.rb", "class_two.rb"], OBJECT_FILE_MAPPINGS.keys
    assert_equal ["ClassOne"], OBJECT_FILE_MAPPINGS['class_one.rb']
    assert_equal ["ClassTwo"], OBJECT_FILE_MAPPINGS['class_two.rb']
  end
  
  def test_object_file_mappings    
    assert_equal 5, OBJECT_REFERENCE_MAPPINGS["ClassOne"].size
    assert_equal "./class_two.rb", OBJECT_REFERENCE_MAPPINGS["ClassOne"].first.file
  end
  
  def test_references
    assert_equal 5, Rreader.references.first.last.count
    assert_equal "ClassTwo", Rreader.references.last.first
  end
  
end