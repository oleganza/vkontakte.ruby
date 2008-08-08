$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')) ).uniq!
require 'set'
require 'fileutils'
require 'vkontakte'
include Vkontakte

SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
TEMP_DIR = SPEC_ROOT + '/temp'
TEMP_STORAGES = TEMP_DIR + '/storages'

Spec::Runner.configure do |config|
  config.before(:all) do
    FileUtils.rm_rf TEMP_STORAGES
    FileUtils.mkdir_p TEMP_STORAGES
  end
  config.after(:all) do
    
  end
end
