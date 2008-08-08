module Vkontakte
  class Model
    # simple model mimicing ActiveRecord's attributes
    # we may probably implement deleltion and updates
    # right from here.
    attr_accessor :attributes
    
    def initialize(attributes)
      self.attributes = attributes
    end
    
    def attributes=(hash)
      hash.each do |k, v|
        self.send :"#{k}=", v
      end
    end    
  end
end