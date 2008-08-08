require 'net/http'

require 'iconv'
require 'cgi'
require 'md5'
require 'jcode'
$KCODE = 'u'


module Vkontakte
  class Account
    attr_accessor :id, :email, :pass
    attr_accessor :authorized
    
    def initialize(*args)
      if (args.size == 1)
        self.id = args.first.to_i
      else
        self.email, self.pass = args
      end      
    end

    def id
      return @id if @id
      authorize
      @id
    end
    
    def params(response) 
      @params ||= {}#UserPage.new(response || request('/'))
    end
    
    def request(url, account = self)
      Request.new(url).as account
    end
    
    def authorize
      self.authorized = !! send_authorization_request
    end
    
    def authorized?
      authorized
    end
    
    def puppetize!
      authorize
      Request.add_puppet(self)
    end
    
    def accessible?
      #I think i really should define NilClass#empty
      (email and not email.empty?) and  (pass and not pass.empty?)
    end
    
  private 
    def send_authorization_request
      response = request('/login.php', nil).post :email => email, :pass => pass
      begin
        self.id = ::CGI::Cookie.parse(response['Set-Cookie'])['remixmid'].first.to_i
      rescue
        raise "Can't sign in with #{email}:#{pass}"
      end
    end
  end
end