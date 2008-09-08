def Controller
  attr_accessor :items
  
  def initialize(items = [])
    self.items = items
  end
  
  def method_missing(*args)
    self.items.each do |i|
      i.send(*args)
    end
  end
  
end