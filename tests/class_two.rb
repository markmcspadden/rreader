class ClassTwo
  attr_accessor :class_one
  
  
  def associate_to_class_one
    self.class_one = ClassOne.new
  end
  
  def find_or_initialize_class_one
    self.class_one ||= ClassOne.new
  end
  
end