module Pigeons
  module Acts
    module Versionable

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods

        # Record changes against this model.
        # Versions are accessible via #versions and ordered by date.
        # By default, each changed field contains an array containing [old,new].
        #
        # Procs may be passed in to customize how each fields changes are stored.
        #
        # class User
        #   
        #   acts_as_versioned :bio => Proc.new { |old,new| #Diff(old,new) }
        #
        # end
        #
        def acts_as_versioned(procs = {})
          has_many(:versions,
                   :as => :versionable,
                   :order => "created_at DESC",
                   :dependent => :destroy,
                   :readonly => :true) 

          after_create Versionator.new(procs) 
          before_update Versionator.new(procs)
        end
      end

      class Versionator

        def initialize(args = {})
          @procs, @data = args, Hash.new
        end

        def before_update(versionable)

          for key in versionable.changes.keys 
            value = @data[key] = versionable.changes[key]

            if @procs.has_key?(key)
              value = @procs[key].call(value[0], value[1])
            end

            @data[key] = value
          end

          versionable.versions.create(:values => @data)
          return true
        end
        alias_method(:after_create, :before_update)

      end

    end
  end
end
