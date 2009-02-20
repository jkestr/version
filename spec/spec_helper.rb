$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'activerecord'
require 'ruby-debug'
require 'spec'

# TODO how do we just include the init for the plugin
require 'version'
require 'versionable'
ActiveRecord::Base.send(:include, Pigeons::Acts::Versionable)

dbconfig = {
  :adapter => 'sqlite3',
  :database => File.join(File.dirname(__FILE__), '..', 'db', 'test.sqlite3')
}

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Migration.verbose = false

class TestMigration < ActiveRecord::Migration
  def self.up

    create_table :versions do |t|
      t.integer :versionable_id
      t.string :versionable_type, :limit => 32
      t.datetime :created_at
      t.text :values
    end
    add_index :versions, [:versionable_id, :versionable_type, :created_at]

    create_table :examples do |t|
      t.string :name
      t.integer :value
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :versions
    drop_table :examples
  rescue
  end
end

def without_changing_the_database
  ActiveRecord::Base.transaction do
    yield
    ActiveRecord::Rollback
  end
end

TestMigration.down
TestMigration.up

