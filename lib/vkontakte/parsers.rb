module Vkontakte
  module Parsers
    module Music

      # content source example: http://vkontakte.ru/audio.php?id=1
      # result example: [{"duration"=>"1:33", "title"=>"The Diva Dance", "performer"=>"Inva Mulla Tchako", 'file' => "http://cs1317.vkontakte.ru/u2613036/audio/d7822781e4.mp3"}, {"duration"=>"5:10", "lyrics"=>"26704098,223884", "title"=>"Confessa", "performer"=>"Adriano Celentano", 'file' => "http://cs1339.vkontakte.ru/u879741/audio/eab111f599.mp3"}]
      def self.parse_personal_list content
        records = content.scan(/onclick="return operate\((.*?)\);".*?<b id="performer\d+?">(.*?)<\/b>.*?id="title\d+?">(.*?)<\/span>.*?class="duration">(.*?)<\/div>/mi)
        records.map!{|item| {'operate' => item[0], 'performer' => item[1], 'title' => item[2], 'duration' => item[3]}}

        records.map! do |item|
          title_parts = item['title'].scan(/<a.*?showLyrics\((.*?)\);'>(.*?)<\/a>/mi)
          title_parts.size > 0 ? {'lyrics' => title_parts[0][0], 'title' => title_parts[0][1], 'operate' => item['operate'], 'performer' => item['performer'], 'duration' => item['duration']} : item        
        end

        records.map! do |item|
          operate_parts = item['operate'].split(',')
          {'lyrics' => item['lyrics'], 'title' => item['title'], 'file' => "http://cs#{operate_parts[1]}.vkontakte.ru/u#{operate_parts[2]}/audio/#{operate_parts[3]}.mp3", 'performer' => item['performer']
        end
      end
    end

    module Video

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

    module Notes

      # content source example: http://vkontakte.ru/notes.php?id=1, http://vkontakte.ru/notes1?&st=0
      # result example: {"notes"=>["note6352523?oid=1", "note5223960?oid=1", "note5188853?oid=1"], "pages"=>["notes1?&amp;st=20"]}
      def self.parse_personal_list content
        notes_records = content.scan(/<div class="note_title".*?a href="(.*?)">.*?<\/a.*?\/div>/mi).flatten
        pages_records = content.scan(/<li><a href='(notes\d+?.+?st=\d+)'>\d+<\/a><\/li>/mi).uniq.flatten
        {'notes' => notes_records, 'pages' => pages_records}
      end

      # content source example: http://vkontakte.ru/note6352523?oid=1
      # result example: {"created_at"=>"5 June 2008 at 4:19", "body"=>"\317\356\367\342\345\360\355\356?\r\n ", "author"=>"Pavel Durov", "title"=>"10 millionov"}
      def self.parse_single_note content
        record = content.scan(/<div class="note_title".*?a href=".*?">(.*?)<\/a.*?div class="byline".*?span><a href="[^"]*?(\d+).*?<\/a><\/span> (.*?\d+:\d+).*?\/div.*?\/div.*?div class="note_content clearFix".*?div>\s*(.*?)\s*<\/div>/mi)
        {'title' => record[0][0], 'author' => record[0][1], 'created_at' => record[0][2], 'body' => record[0][3]}
      end
    end

    module Friends

      # content source example: http://vkontakte.ru/friend.php?id=2325643
      # result example: ["3947147", "5953678", "5886400"]
      def self.parse_personal_list content
        content.scan(/\[(\d+?), \{f:'.+?', l:'.+?'\},\{p:.*?u:\d+\}\]/mi).map!{|item| item[0]}
      end
    end

    module Profile

      # content source example: http://vkontakte.ru/profile.php?id=585655
      # result example: //TODO fill this according to the changes in the output
      def self.parse_profile content
        basic = parse_table(content.scan(/basicInfo(.*?)\/table/mi)[0][0])

        contacts = parse_table(content.scan(/Contact Information(.*?)\/table/mi)[0][0])
        personal = parse_table(content.scan(/Personal Information(.*?)\/table/mi)[0][0])
        #I know we should not rely on localized strings in parsers, cant help it.
        
        status = content.match(/activity_text[^>]*>(.*?)</)[1]
        
        {:basic => basic, :personal => personal, :contacts => contacts, :status => status}
      end
      
      private
        def self.parse_table(content)
          rows = content.scan(/label">(.+?):<\/td.*?dataWrap">\s*(.*?)\s*<\/div>/mi)
          rows.delete_if{|key, value| value =~ /<\/span>/} # removing span with innerHTML = 'secured information'
          rows.map! do |key, value| # url normalizing
            url = value.scan(/<a.*?>(.*?)<\/a>/mi)
            url.size > 0 ? {key => url[0][0]} : {key => value}
          end
        end
    end
  end
end
