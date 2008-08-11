module Vkontakte
  class Note < Model
    attr_accessor :url, :created_at, :title, :author, :body, :parser
    
    def initialize(url, &block)
      self.parser = block
      self.url = url
    end
    
    def author=(id)
      @author = User.new(id)
    end
    
    %w[created_at title author body].each do |m|
      class_eval %{
        def #{m} 
          return @#{m} if @#{m}
          fetch
          @#{m}
        end        
      }     
    end
    
    def fetch
      self.attributes = parser.call(self.url)
      p parser.call(self.url)
    end
    
  end
end