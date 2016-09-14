module PaperTrail
  module AttributeSerializers
    class CastAttributeSerializer
      alias_method :old_serialize, :serialize
      alias_method :old_deserialize, :deserialize

      def serialize(attr, val)
        # Special case for enumerize gem
        return defined_enumerize_enums[attr].find_value(val).to_s if defined_enumerize_enums[attr]

        old_serialize(attr, val)
      end

      def deserialize(attr, val)
        # Special case for enumerize gem
        return defined_enumerize_enums[attr].find_value(val) if defined_enumerize_enums[attr]

        old_deserialize(attr, val)
      end

      private

      def defined_enumerize_enums
        @enumerized_attributes ||=
          if defined?(Enumerize) && @klass.respond_to?(:enumerized_attributes)
            @klass.enumerized_attributes
          else
            {}
          end
      end
    end
  end

  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    self.abstract_class = true
  end
end
