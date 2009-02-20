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
        #   acts_as_versioned :bio => Proc.new { |old, knew| Diff(old, knew) }
        #
        # end
        #
        # You can also control what fields are tracked using :except and :only.
        #
        # class User
        #
        #   acts_as_versioned :only => [:name_first, :name_last, :workflow_state]
        #
        # end
        #
        # class Post
        #
        #   acts_as_versioned :except => :raw_source
        #
        # end
        #
        def acts_as_versioned(args = {})
          has_many(:versions,
                   :as => :versionable,
                   :order => "created_at DESC",
                   :dependent => :destroy,
                   :readonly => :true) 

          options          = Hash.new
          options[:procs]  = args.reject { |k,v| k == :only || k == :except }
          options[:fields] = generate_attribute_list(args[:only], args[:except])

          versionator = Versionator.new(options)
          after_create versionator 
          before_update versionator
        end

        private

        def generate_attribute_list(only, except)
          result = self.new.attribute_names

          result &= [only].flatten.collect(&:to_s) unless only.blank?
          result -= [except].flatten.collect(&:to_s) unless except.blank?

          return result
        end

      end

      class Versionator

        def initialize(options = {})
          @procs  = options[:procs] || {}
          @fields = options[:fields] || []
        end

        def before_update(versionable)
          values = versionable.changes.dup
          values.delete_if { |k,v| !@fields.include?(k)}

          for key in @procs.keys
            values[key.to_s] = @procs[key].call(values[key.to_s])  
          end

          versionable.versions.create(:values => values)

          return true
        end
        alias_method(:after_create, :before_update)

      end

    end
  end
end
