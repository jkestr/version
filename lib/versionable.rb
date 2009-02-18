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
        #   # Just an example, there is no diff library like this that I know of...
        #   acts_as_versioned :bio => Proc.new { |old,new| Diff(old,new) }
        #
        # end
        #
        def acts_as_versioned(args = {})
          has_many(:versions,
                   :as => :versionable,
                   :order => "created_at DESC",
                   :dependent => :destroy,
                   :readonly => :true) 

          if args.has_key?(:only)
            args[:fields] = attribute_names & args.delete(:only)
          elsif args.has_key?(:except)
            args[:fields] = attribute_names - args.delete(:except)
          else
            args[:fields] = attribute_names
          end
          
          after_create Versionator.new(args) 
          before_update Versionator.new(args)
        end
      end

      class Versionator

        def initialize(args = {})
          @fields = args.delete(:fields)
          @procs, @data = args, Hash.new
        end

        def before_update(versionable)

          for field in versionable.changes.keys & @fields 

            unless @procs.has_key?(key)
              @data[key] = versionable.changes[key]
            else
              @data[key] = @procs[key].call(value[0], value[1])
            end

          end

          versionable.versions.create(:values => @data)

          return true
        end
        alias_method(:after_create, :before_update)

      end

    end
  end
end
