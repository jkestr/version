require 'version'
require 'versionable'
ActiveRecord::Base.send(:include, Pigeons::Acts::Versioned)
