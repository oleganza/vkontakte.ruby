require 'base_parser'

module Parsers
  class Music
    extend BaseParser

    # content example: http://vkontakte.ru/audio.php?id=1
    # result example: [{"duration"=>"1:33", "title"=>"The Diva Dance", "performer"=>"Inva Mulla Tchako"}, {"duration"=>"5:10", "lyrics"=>"26704098,223884", "title"=>"Confessa", "performer"=>"Adriano Celentano"}]
    def self.parse_personal_list content
      records = content.scan(/<b id="performer\d+?">(.*?)<\/b>.*?id="title\d+?">(.*?)<\/span>.*?class="duration">(.*?)<\/div>/mi)
      records.map!{|item| {'performer' => item[0], 'title' => item[1], 'duration' => item[2]}}

      records.map! do |item|
        title_parts = item['title'].scan(/<a.*?showLyrics\((.*?)\);'>(.*?)<\/a>/mi)
        title_parts.size > 0 ? {'lyrics' => title_parts[0][0], 'title' => title_parts[0][1], 'performer' => item['performer'], 'duration' => item['duration']} : item        
      end

      records
    end
  end
end
