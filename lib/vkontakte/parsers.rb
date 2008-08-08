require 'vkontakte/parsers/base_parser'
require 'vkontakte/parsers/working_parsers'

module Vkontakte
  module ParserWrapper
    def music
      Parsers::Music.parse_personal_list(request("/audio.php").get_personalized.body).map {|m| Music.new m}
    end
    alias audios music
    
    def videos
      Parsers::Video.parse_personal_list(request("/video.php").get_personalized.body).map {|v| Video.new v}
    end
    
    def notes
      Parsers::Notes.parse_personal_list(request("/notes.php").get_personalized.body)["notes"].map do |n| 
        Note.new(n) do |url|
          Parsers::Notes.parse_single_note request(url).get.body
        end
      end
    end
    
    def friends
      Parsers::Friends.parse_personal_list(request("/friend.php").get_personalized.body).map {|f| User.new f}
    end
    
    def contacts
      Parsers::Contacts.parse_contacts(homepage.get.body)
    end
    
  end
  
  User.class_eval do 
    include ParserWrapper
  end
end
