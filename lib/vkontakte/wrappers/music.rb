module Vkontakte
  class Music < Model
    attr_accessor :performer, :title, :duration, :file_url, :lyrics
    
    def request
      Request.new(file_url).get
    end
    
    def contents
      request.body
    end
  end
end