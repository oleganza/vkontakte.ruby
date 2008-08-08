module VkontakteRuby
  class Cookies
    PREFIX = 'remix'.freeze
    
    attr_accessor :id, :email, :pass
    
    def initialize(user)
      @id       = user.id 
      @email    = user.email    or raise "No Email given"
      @pass     = user.pass or raise "No pass given"
    end
    
    def id
      @id || User.new(@email, @pass).id
    end
    
    def pass
      MD5.new @pass
    end
    
    def to_hash
      {
        "#{PREFIX}email" => email,
        "#{PREFIX}pass" => pass,
        "#{PREFIX}mid" => id,
        "#{PREFIX}chk" => 5,
        "#{PREFIX}lang" => 1
      }
    end
    
    def to_params
      to_hash.to_params
    end
    
    def to_s
      to_params.gsub('&', '; ')
    end
  end
  
  class Request
    DOMAIN = 'vkontakte.ru'.freeze
    
    attr_accessor :path, :user, :cookies
    
    def initialize(path = '/')
      self.path = path
    end
    
    def as(user)
      self.user = user
      self.cookies = Cookies.new(user).to_s if user
      self
    end
    
    def get_personalized(params = {}, person = user)
      with_params :id => person.id do
        get(params)
      end
    end
    
    def get(params = {})
      handle :get, headers
    end
    alias to_s get
    
    def post(params)
      handle :post, params.to_params, headers
    end
    
    private
      def connection
        @connection ||= Net::HTTP.start DOMAIN
      end
      
      def handle(method, *args)
        #rescue proxy unvailability thing here
        begin
          args.insert 0, path
          r = connection.send method, *args
          p method, *args
          r
        rescue Net::HTTPBadResponse => e
          raise "Cant handle the request because of #{e.inspect}"
        end
      end
      
      def convert(string)
        Iconv.iconv("UTF-8", "CP1251", string)
      end
      
      def headers
        hash = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1',
          'Referer' => "http://#{DOMAIN}/index.php"
        }
        hash['Cookie'] = self.cookies if self.cookies and not self.cookies.empty?
        hash
      end
      
      def with_params(params, &block)
        return block.call if params.empty?
        
        old_path = self.path
        self.path += "?" + params.to_params
        result = block.call
        self.path = old_path
        result
      end
  end
end