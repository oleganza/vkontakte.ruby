require 'rubygems'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), 'vkontakte')) ).uniq!

module Vkontakte
  VERSION = "0.1"
end

require 'vkontakte/request'
require 'vkontakte/user'
require 'vkontakte/parser_wrapper'

require 'vkontakte/parsers/base_parser'
require 'vkontakte/parsers/working_parsers'
require 'vkontakte/console'
