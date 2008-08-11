module Vkontakte
  class Cookies
    PREFIX = 'remix'.freeze
    
    attr_accessor :id, :email, :pass
    
    def initialize(user)
      return unless user
      @id       = user.id 
      @email    = user.email or raise "No Email given"
      @pass     = user.pass  or raise "No pass given"
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
        "#{PREFIX}lang" => 3
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
    
    class << self
      def puppets
        @puppets ||= []
      end
      
      def add_puppet(user)
        puppets << user if user.authorized?
      end
      
      def free_puppet
        #here we can check if puppet is requesting something and is busy
        #but we dont ;]
        puppets[(rand * puppets.size).floor - 1]
      end
    end
    
    attr_accessor :path, :user, :cookies, :host
    
    def initialize(uri = '/')
      self.host, self.path = 
      if uri.index "http://"
        parsed = URI.parse(uri)
        [parsed.host, parsed.path]
      else
        [DOMAIN, uri]
      end
    end
    
    def as(user)
      self.user = user
      self
    end
    
    def get_personalized(params = {}, person = user)
      with_params :id => person.id do
        get(params)
      end
    end
    
    def get(params = {})
      with_params params do
        handle :get, headers
      end
    end
    alias to_s get
    
    def post(params)
      handle :post, params.to_params, headers
    end
    
    private
      def connection
        @connection ||= Net::HTTP.start host
      end
      
      def handle(method, *args)
        #rescue proxy unvailability thing here
        begin
          args.insert 0, (path[0,1] == "/" ? path : "/#{path}")
          response = connection.send method, *args
          response.instance_eval do 
            alias old_body body
            def body 
              Iconv.iconv("UTF-8", "CP1251", old_body).first
            end
          end
          
            p path
          
          if Net::HTTPRedirection === response
            raise "You should log this user in or choose a puppet"  if response['Location'].index "login"
          end
          response
        rescue Net::HTTPBadResponse => e
          raise "Cant handle the request because of #{e.inspect}"
        end
      end
      
      def headers
        hash = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1',
          'Referer' => "http://#{DOMAIN}/index.php",
          'Cookie' => puppet ? Cookies.new(puppet).to_s : ''
        }
      end
      
      def with_params(params, &block)
        return block.call if params.empty?
        
        old_path = self.path
        self.path += (self.path.index("?") ? "&" : "?") + params.to_params
        result = block.call
        self.path = old_path
        result
      end
      
      def puppet
        self.user && self.user.accessible? ? self.user : self.class.free_puppet 
      end
  end
end