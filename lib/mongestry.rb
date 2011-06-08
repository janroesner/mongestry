module Mongestry

  class << self.class.superclass
    def has_mongestry
      include Mongestry::InstanceMethods
      field :ancestry, type: String
      field :persisted_depth, type: Integer
      before_create :build_ancestry
    end
  end

  module InstanceMethods

    def self.included base
      base.extend Mongestry::ClassMethods
    end

    def build_ancestry
      raise "Either parent or parent_id can be given, not both at once" if self.attributes.keys.include?("parent") and self.attributes.keys.include?("parent_id")
      return unless self.respond_to?(:parent) or self.respond_to?(:parent_id)

      parent = self.class.object_for(self.attributes["parent"] || self.attributes["parent_id"])

      self.ancestry = nil unless parent
      self.ancestry = parent.ancestry.nil? ? parent.id.to_s : parent.ancestry.to_s + "/#{parent.id.to_s}" if parent
      self.persisted_depth = parent.depth + 1 rescue 0

      self.attributes.delete("parent")
      self.attributes.delete("parent_id")
    end

    # Returns a list of ancestor ids, starting with the root id and ending with the parent id
    def ancestor_ids
      self.ancestry.split('/').collect{ |s| BSON::ObjectId.from_string s }
    end

    # Scopes the model on ancestors of the record
    def ancestors
      self.class.where(_id: {"$in" => self.ancestor_ids})
    end

    # Returns the parent of the record, nil for a root node
    def parent
      self.class.where(_id: self.ancestry.split('/').last) rescue nil
    end

    # Returns the id of the parent of the record, nil for a root node
    def parent_id
      self.parent.first.id rescue nil
    end

    # Returns the root of the tree the record is in, self for a root node
    def root
      self.class.where(_id: self.ancestry.split('/').first)
    end

    # Returns the id of the root of the tree the record is in
    def root_id
      self.root.first.id
    end

    # Returns true if the record is a root node, false otherwise
    def is_root?
      self.ancestry.nil?
    end

    # Scopes the model on children of the record
    def children
      case self.is_root?
      when true
        self.class.where(:ancestry => self.ancestry.to_s + "#{self.id.to_s}")
      else
        self.class.where(:ancestry => self.ancestry.to_s + "/#{self.id.to_s}")
      end
    end

    # Returns a list of child ids
    def child_ids
      self.children.map(&:id)
    end

    # Returns true if the record has any children, false otherwise
    def has_children?
      !self.children.to_a.blank?
    end

    # Returns true if the record has no childen, false otherwise
    def is_childless?
      !self.has_children?
    end

    # Scopes the model on siblings of the record, the record itself is included
    def siblings
      self.class.where(:ancestry => self.ancestry.to_s).and((Mongoid::Criterion::Complex.new key: :_id, operator: 'ne') => self.id)
    end

    # Returns a list of sibling ids
    def sibling_ids
      self.siblings.map(&:id)
    end

    # Returns true if the record's parent has more than one child
    def has_siblings?
      !self.siblings.blank?
    end

    # Returns true if the record is the only child of its parent
    def is_only_child?
      !self.has_siblings?
    end

    # Scopes the model on direct and indirect children of the record
    def descendants
      expression = self.is_root? ? self.id.to_s : (self.ancestry + "/#{self.id.to_s}").split('/').join('\/')
      self.class.where(:ancestry => Regexp.new(expression))
    end

    # Returns a list of a descendant ids
    def descendant_ids
      self.descendants.map(&:id)
    end

    # Scopes the model on descendants and itself
    def subtree
      self.class.where(_id: {"$in" => self.descendant_ids.push(self.id)})
    end

    # Returns a list of all ids in the record's subtree
    def subtree_ids
      self.subtree.map(&:id)
    end

    # Return the depth of the node, root nodes are at depth 0
    def depth
      self.ancestry.split('/').size rescue 0
    end

    protected

  end

  module ClassMethods

    def object_for identifier
      case identifier.class.to_s
      when "BSON::ObjectId"
        self.find identifier
      when self.to_s
        identifier
      end
    end

    #Root nodes
    def roots
      self.where(ancestry: nil)
    end

    # Ancestors of node, node can be either a record or an id
    def ancestors_of node
      node.ancestors
    end

    # Children of node, node can be either a record or an id
    def children_of node
      node.children
    end

    # Descendants of node, node can be either a record or an id
    def descendants_of node
      node.descendants
    end

    # Subtree of node, node can be either a record or an id
    def subtree_of node
      node.subtree
    end

    # Siblings of node, node can be either a record or an id
    def siblings_of node
      node.siblings
    end

    # Return nodes that are less deep than depth (node.depth < depth)
    def before_depth depth
      self.where(persisted_depth: {"$lt" => depth})
    end

    # Return nodes up to a certain depth (node.depth <= depth)
    def to_depth depth
      self.where(persisted_depth: {"$lte" => depth})
    end

    # Return nodes that are at depth (node.depth == depth)
    def at_depth depth
      self.where(persisted_depth: depth)
    end

    # Return nodes starting from a certain depth (node.depth >= depth)
    def from_depth depth
      self.where(persisted_depth: {"$gte" => depth})
    end

    # Return nodes that are deeper than depth (node.depth > depth)
    def after_depth depth
      self.where(persisted_depth: {"$gt" => depth})
    end

  end

end
