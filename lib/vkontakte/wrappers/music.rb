module Vkontakte
  class Music < Model
    attr_accessor :performer, :title, :duration, :url
    
    def request
      Request.new(url).get
    end
    
    def contents
      request.body
    end
  end
end