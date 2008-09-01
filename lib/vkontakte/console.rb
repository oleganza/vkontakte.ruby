require 'irb'
module Vkontakte
  module Console
    include Vkontakte
    def initialize_console
      puts "Vkontakte v#{Vkontakte::VERSION} (help! for more info)"
    end
    
    def login
      email    = prompt_email(ENV['VKONTAKTE_EMAIL'])
      password = prompt_password
      User.new(email, password)
    end

    def prompt_password
      print "Password: "
      p = no_echo { gets.chomp }
      puts
      if p == ""
        return prompt_password
      else
        p
      end
    end
    
    def prompt_email(default = nil)
      e = default ? " [press enter to choose #{default}]" : ""
      print "Email#{e}: "
      r = gets.chomp
      if r == ""
        if default
          puts "Using #{default}"
          return default
        end
        return prompt_email
      else
        r
      end
    end
    
    def no_echo
      begin
        system("stty -echo")
        yield
      ensure
        system("stty echo")
      end
    end
    
    def help!
      puts %{
  reload!   Reloads console environment.
  
Usage example:

  me = User.new "invizko@gmail.com", "whatever"
  me.id #=> 5567476 
  me.videos #=> [{"duration"=>"4:17", "title"=>"Gabriel", "performer"=>"Lamb", "operate"=>"40134438,1522,5567476,'2ca4745378',257"}, {"duration"=>"1:14", "title"=>"Generation of Terror", "performer"=>"Fexamot", "operate"=>"39117745,1527,5567476,'7b61c70c8a',74"}...]

  me.friends.each do |f|
    friend = User.new(f) #created by-id
    if friend.friends.any? {|ff| ff == me.id }
      p "\#{friend.name} is your mutual friend"
    else
      p "\#{friend.name} is not your friend at all."

      # Maybe something like friend.invite_by(me) here?
    end
  end}
    end
    
    def reload!
      exec($0)
    end
    
    
  end
end
