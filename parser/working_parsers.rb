require 'base_parser'

module Parsers
  class Music
    extend BaseParser

    def self.parse_personal_list content
      puts content
    end
  end
end
