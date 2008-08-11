module Vkontakte
  class Note < Model
    attr_accessor :url, :parser
    attr_lazy :created_at, :title, :author, :body, :with => :fetch
    
    def initialize(url, &block)
      self.parser = block
      self.url = url
    end
    
    def author=(id)
      @author = User.new(id)
    end
    
    private
    
      def fetch
        self.attributes = parser.call(self.url)
      end
    
  end
end