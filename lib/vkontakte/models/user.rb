module Vkontakte
  class User < Model
  
    attr_lazy :personal, :contacts, :status, :basic, :with => :fetch_personal
  
    include Account
    
    def male?
      basic['Sex'] == "Male"
    end
    
    def female?
      not male?
    end
    
    def name
      "Fedot Ivanov"
    end
    
    def summary
      [name, personal['Hometown']].compact * ", "
    end
    
    def summary_with_status
      [summary + status].compact * "\n"
    end
    
    
    
    def homepage
      request("/id#{id}")
    end
    
    def music
      Parsers::Music.parse_personal_list(request("/audio.php").get_personalized.body).map {|m| Music.new m}
    end
    alias audios music
    
    def videos
      Parsers::Video.parse_personal_list(request("/video.php").get_personalized.body).map do |v| 
        Video.new(v) do |url|
          Parsers::Video.parse_single_video request(url).get.body
        end
      end
    end
    
    def notes(mode = :all)
      url = case mode
      when :favorites
        "/notes.php?act=fave"
      when :friends
        "/notes.php?act=friends"
      when :all
        "/notes.php"
      end
      Parsers::Notes.parse_personal_list(request(url).get_personalized.body)["notes"].map do |n| 
        Note.new(n) do |url|
          Parsers::Notes.parse_single_note request(url).get.body
        end
      end
    end
    
    def friends(mode = :all)
      url = case mode
      when :online
        "/notes.php?act=online"
      when :all
        "/notes.php"
      end
      Parsers::Friends.parse_personal_list(request(url).get_personalized.body).map {|f| User.new f}
    end
    
    private
      def fetch_personal
        self.attributes ||= Parsers::Profile.parse_profile(homepage.get.body)
      end    
  end
end
