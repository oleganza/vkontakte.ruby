require 'rubygems'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), 'vkontakte')) ).uniq!

module Vkontakte
  VERSION = "0.1"
end

require 'vkontakte/core_ext/hash'

require 'vkontakte/util/smtp_server'
require 'vkontakte/request'
require 'vkontakte/account'

require 'vkontakte/wrappers/model'
require 'vkontakte/wrappers/user'
require 'vkontakte/wrappers/video'
require 'vkontakte/wrappers/music'
require 'vkontakte/wrappers/note'

require 'vkontakte/parsers'
require 'vkontakte/console'