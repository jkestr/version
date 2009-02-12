class Version < ActiveRecord::Base
  
  # It would be nice if this could be #fields or #changes and not kill 
  # ActiveRecord down in the class.
  serialize :values, Hash

  belongs_to :versionable, :polmorphic => true

  # Returns the stored value for field.
  # Version#[:field] # => Version#data.[:field]
  def[](field)
    return self.values[field]
  end

end
