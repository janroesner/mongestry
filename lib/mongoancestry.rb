module MongoAncestry

  class << self.class.superclass
    def has_mongo_ancestry
      include MongoAncestry::InstanceMethods
      field :ancestry, type: String
      before_create :build_ancestry
    end
  end

  module InstanceMethods

    def self.included base
      base.extend MongoAncestry::ClassMethods
    end

    def build_ancestry
      raise "Either parent or parent_id can be given, not both at once" if self.attributes.keys.include?("parent") and self.attributes.keys.include?("parent_id")
      return unless self.respond_to?(:parent) or self.respond_to?(:parent_id)

      parent = parent_object(self.attributes["parent"] || self.attributes["parent_id"])
      raise "Given parent node was not found, please provide an object ot the object_id of the parent node." unless parent

      self.ancestry = parent.ancestry.nil? ? parent.ancestry.to_s + parent.id.to_s : parent.ancestry.to_s + "/#{parent.id.to_s}"

      self.attributes.delete("parent")
      self.attributes.delete("parent_id")
    end

    def ancestor_ids
      self.ancestry.split('/').collect{ |s| BSON::ObjectId.from_string s }
    end

    def ancestors
      self.class.find self.ancestor_ids
    end

    def parent
      self.class.find self.ancestry.split('/').last
    end

    def parent_id
      self.parent.id
    end

    def root
      self.class.find self.ancestry.split('/').first
    end

    def root_id
      self.root.id
    end

    def is_root?
      self.ancestry.nil?
    end

    def children
      case self.is_root?
      when true
        self.class.where(:ancestry => self.ancestry.to_s + "#{self.id.to_s}")
      else
        self.class.where(:ancestry => self.ancestry.to_s + "/#{self.id.to_s}")
      end
    end

    def child_ids
      self.children.map(&:id)
    end

    def has_children?
      !self.children.to_a.blank?
    end

    def is_childless?
      !self.has_children?
    end

    def siblings
      self.class.where(:ancestry => self.ancestry.to_s).and((Mongoid::Criterion::Complex.new key: :_id, operator: 'ne') => self.id)
    end

    protected

    def parent_object identifier
      case identifier.class.to_s
      when "BSON::ObjectId"
        self.class.find identifier
      when self.class.to_s
        identifier
      end
    end

  end

  module ClassMethods
    def foo
      puts "I am a class method"
    end
  end

end
