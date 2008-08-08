require 'rubygems'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), 'vkontakte')) ).uniq!

require 'vkontakte/request'
require 'vkontakte/user'
require 'vkontakte/parser_wrapper'

require 'vkontakte/parsers/base_parser'
require 'vkontakte/parsers/working_parsers'