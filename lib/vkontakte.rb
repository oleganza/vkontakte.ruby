require 'rubygems'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), 'vkontakte')) ).uniq!

module Vkontakte
  VERSION = "0.1"
end

require 'net/http'

require 'iconv'
require 'cgi'
require 'md5'

$KCODE = 'u'

require 'vkontakte/core_ext/hash'

require 'vkontakte/util/smtp_server'
require 'vkontakte/request'
require 'vkontakte/parsers'

require 'vkontakte/models/account'
require 'vkontakte/models/model'
require 'vkontakte/models/user'
require 'vkontakte/models/video'
require 'vkontakte/models/music'
require 'vkontakte/models/note'

require 'vkontakte/console'