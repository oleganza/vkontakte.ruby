require 'vkontakte/parsers/base_parser'
require 'vkontakte/parsers/working_parsers'

module Vkontakte
  module ParserWrapper
    def music
      Parsers::Music.parse_personal_list request("/audio.php").get_personalized.body
    end
    alias audios music
    
    def videos
      Parsers::Music.parse_personal_list request("/video.php").get_personalized.body
    end
    
    def notes
      Parsers::Music.parse_personal_list request("/notes.php").get_personalized.body
    end
    
    def friends
      Parsers::Music.parse_personal_list request("/friend.php").get_personalized.body
    end
    
  end
  
  User.class_eval do 
    include ParserWrapper
  end
end
