class ClassOne
  attr_accessor :class_two
  
  def associate_to_class_two
    self.class_two = ClassTwo.new
  end
end