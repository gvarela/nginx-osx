$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'nginx-osx'

require 'test/unit/assertions'

World(Test::Unit::Assertions)
