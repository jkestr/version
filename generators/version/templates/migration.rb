class <%= migration_name %> < ActiveRecord::Migration

  def self.up
    create_table :versions do |t|
      t.integer, :versionable_id
      t.string, :versionable_type, :limit => 32
      t.datetime, :created_at
      t.text, :values
    end
    add_index :versions, [:versionable_id, :versionable_type, :created_at]
  end

  def self.down
    drop_table :versions
  end

end
