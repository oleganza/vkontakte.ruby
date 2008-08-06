require 'curb'

class Hash
  def stringify_keys
    inject({}) do |options, (key, value)|
      options[key.to_s] = value
      options
    end
  end 
end  

module VkontakteRuby
  # Bot to grab vkontakte.ru pages with autologin feature
  # ==== Example
  #  Bot.new(:login => "Somelogin", :passwod => "Somepassword").get("http://vkontakte.ru/id1")
  class Bot
    LOGIN_URL = "http://vkontakte.ru/login.php"
    attr_reader :response
    
    def initialize(options = {})
      @options = options.stringify_keys    
      @curl = Curl::Easy.new do |curl|
        curl.follow_location = true
        curl.enable_cookies = true  
        curl.cookiejar = 'cookiejar.txt' 
      end      
      login
    end
    
    # Perform GET request and returns request result  
    def get(url)
      @curl.url = url
      @curl.perform
      @curl.body_str
    end
    
    # Perform POST request and returns request result  
    # ==== Example
    # Bot.new(:login => "Somelogin", :passwod => "Somepassword").put("http://vkontakte.ru/id1", {:somefield => "somevalue"})
    def put(url, fields = {}) 
      @curl.url = url
      @curl.http_post(url, fields.stringify_keys.map{|k,v| Curl::PostField.content(k,v)})
      @curl.body_str         
    end
      
    private 
    
    def login
      @curl.url = LOGIN_URL
      @curl.headers['Referer'] = LOGIN_URL
      put(LOGIN_URL, {:try_to_login=> "1",:success_url => "",:fail_url=>"", :email=>  @options['login'], :pass=>@options['password'] })
      raise "Can't login. Wrong username or password." if @curl.body_str =~ /<div id='error'>.*?<\/div>/  
    end
  end
end
