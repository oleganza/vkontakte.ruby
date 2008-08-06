require 'base_parser'

module Parsers
  class Music
    extend BaseParser

    # content source example: http://vkontakte.ru/audio.php?id=1
    # result example: [{"duration"=>"1:33", "title"=>"The Diva Dance", "performer"=>"Inva Mulla Tchako", 'operate' => '38491088,1317,2613036,\'d7822781e4\',220'}, {"duration"=>"5:10", "lyrics"=>"26704098,223884", "title"=>"Confessa", "performer"=>"Adriano Celentano", 'operate' => '26911711,1339,879741,\'eab111f599\',157'}]
    def self.parse_personal_list content
      records = content.scan(/onclick="return operate\((.*?)\);".*?<b id="performer\d+?">(.*?)<\/b>.*?id="title\d+?">(.*?)<\/span>.*?class="duration">(.*?)<\/div>/mi)
      records.map!{|item| {'operate' => item[0], 'performer' => item[1], 'title' => item[2], 'duration' => item[3]}}

      records.map! do |item|
        title_parts = item['title'].scan(/<a.*?showLyrics\((.*?)\);'>(.*?)<\/a>/mi)
        title_parts.size > 0 ? {'lyrics' => title_parts[0][0], 'title' => title_parts[0][1], 'operate' => item['operate'], 'performer' => item['performer'], 'duration' => item['duration']} : item        
      end
    end
  end

  class Video
    extend BaseParser

    # content source example: http://vkontakte.ru/video.php?id=1
    # result example: [{"created_at"=>"3 \340\342\343\363\361\362\340 2008", "title"=>"\323\354\340\362\356\342\373\351 \344\356\353\343\356\357\377\362", "description"=>"\315\345 \354\345\370\340\351\362\345 \345\354\363, \356\355 \352\363\370\340\345\362."}, {"created_at"=>"30 \350\376\355\377 2008", "title"=>"Hitla in da contakta", "description"=>"dast ist kaput"}, {"created_at"=>"14 \354\340\377 2008", "title"=>"Italians", "description"=>""}]
    def self.parse_personal_list content
      records = content.scan(/<div class="aname"><a href="video.+?">(.*?)<\/a><\/di.*?="adesc">(.*?)<\/d.*?class="ainfo">.*? (.*?)<\/div>/mi)
      records.map!{|item| {'title' => item[0], 'description' => item[1], 'created_at' => item[2]}}

      records.map! do |item|
        item['description'].size > 0 ? item : {'title' => item['title'], 'created_at' => item['created_at']}
      end
    end 
  end
end
