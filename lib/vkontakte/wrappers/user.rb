module Vkontakte
  class User < Account
    
    def homepage
      request("/id#{id}")
    end
    
  end
end
