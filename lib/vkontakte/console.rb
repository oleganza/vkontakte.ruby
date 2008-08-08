require 'irb'
module Vkontakte
  module Console
    
    def initialize_console
      puts "Vkontakte v#{Vkontakte::VERSION} (help! for more info)"
    end
    
    def help!
      puts %{
  reload!   Reloads console environment.
  
Usage example:

  me = Vkontakte::User.new "invizko@gmail.com", "whatever"
  me.id #=> 5567476 
  me.videos #=> [{"duration"=>"4:17", "title"=>"Gabriel", "performer"=>"Lamb", "operate"=>"40134438,1522,5567476,'2ca4745378',257"}, {"duration"=>"1:14", "title"=>"Generation of Terror", "performer"=>"Fexamot", "operate"=>"39117745,1527,5567476,'7b61c70c8a',74"}...]

  me.friends.each do |f|
    friend = VkontateRuby::User.new(f) #created by-id
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
