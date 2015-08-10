module ActiveRecord
  
  class Base
    
    def self.reflect_on_all_associations
      base_class.instance_eval { @associations ||= superclass.instance_eval { (@associations && @associations.dup) || [] } }
    end
    
    def self.reflect_on_association(attribute)
      reflect_on_all_associations.detect { |association| association.attribute == attribute }
    end
  
  end
  
  module Associations
    
    class AssociationReflection
      
      attr_reader :association_foreign_key
      attr_reader :attribute
      attr_reader :macro
            
      def initialize(owner_class, macro, name, options = {})
        #puts "new association reflection ()#{owner_class}, #{macro}, #{name}, #{options}) #{owner_class.reflect_on_all_associations}"
        owner_class.reflect_on_all_associations << self
        @owner_class = owner_class
        @macro =       macro
        @klass_name =  options[:class_name] || (collection? && name.camelize.gsub(/s$/,"")) || name.camelize
        @association_foreign_key = options[:foreign_key] || (macro == :belongs_to && "#{name}_id") || "#{@owner_class.name.underscore}_id"
        @attribute =   name
      end
      
      def inverse_of
        unless @inverse_of
          inverse_association = klass.reflect_on_all_associations.detect { | association | association.association_foreign_key == @association_foreign_key }
          raise "Association #{@owner_class}.#{attribute} (foreign_key: #{@association_foreign_key}) has no inverse in #{@klass_name}" unless inverse_association
          @inverse_of = inverse_association.attribute
        end
      end
      
      def klass
        @klass ||= Object.const_get(@klass_name)
      end
      
      def collection?
        [:has_many].include? @macro
      end
      
    end
    
  end
  
  
end