class Version < ActiveRecord::Base
  
  # It would be nice if this could be #fields or #changes and not kill 
  # ActiveRecord down inside the class.
  serialize :values, Hash

  belongs_to :versionable, :polymorphic => true

  # Returns the stored value for field.
  # Version#[:field] # => Version#data.[:field]
  def[](field)
    return self.values[field.to_s]
  end

end
