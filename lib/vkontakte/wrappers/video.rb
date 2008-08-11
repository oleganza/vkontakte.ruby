module Vkontakte
  class Video < Model
    attr_accessor :created_at, :title, :description, :parser, :url
    attr_lazy :file_url, :thumbnail_url, :with => :fetch

    def initialize(*args, &block)
      self.parser = block
      super *args
    end
    
    def request
      Request.new(file_url).get
    end
    
    def contents
      request.body
    end
        
    private
      def fetch
        self.attributes = parser.call(self.url)
      end
    
  end
end