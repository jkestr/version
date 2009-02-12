class ActiveQueueGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|

      m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "CreateVersions"
      }, :migration_file_name => "create_verisions"

    end
  end

end
