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
    
    private
      def self.attr_lazy(*args)
        fetch = (Hash === args.last) ? args.slice!(-1)[:with] : :fetch
        args.each do |m|
          class_eval %{
            attr_writer :#{m}

            def #{m} 
              return @#{m} if @#{m}
              #{fetch}
              @#{m}
            end        
          }     
        end
      end
    
  end
end