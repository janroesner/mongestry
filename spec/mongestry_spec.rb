require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def initialize_country_tree
  @root        = Category.create!(name: "Root",        persisted_depth: 0)
  @germany     = Category.create!(name: "Germany",     persisted_depth: 1, ancestry: "#{@root.id}")
  @switzerland = Category.create!(name: "Switzerland", persisted_depth: 1, ancestry: "#{@root.id}")
  @austria     = Category.create!(name: "Austria",     persisted_depth: 1, ancestry: "#{@root.id}")
  @berlin      = Category.create!(name: "Berlin",      persisted_depth: 2, ancestry: "#{@root.id}/#{@germany.id}")
  @munich      = Category.create!(name: "Munich",      persisted_depth: 2, ancestry: "#{@root.id}/#{@germany.id}")
  @hamburg     = Category.create!(name: "Hamburg",     persisted_depth: 2, ancestry: "#{@root.id}/#{@germany.id}")
  @bern        = Category.create!(name: "Bern",        persisted_depth: 2, ancestry: "#{@root.id}/#{@switzerland.id}")
  @zurich      = Category.create!(name: "Zurich",      persisted_depth: 2, ancestry: "#{@root.id}/#{@switzerland.id}")
  @vienna      = Category.create!(name: "Vienna",      persisted_depth: 2, ancestry: "#{@root.id}/#{@austria.id}")
  @graz        = Category.create!(name: "Graz",        persisted_depth: 2, ancestry: "#{@root.id}/#{@austria.id}")
  @pankow      = Category.create!(name: "Pankow",      persisted_depth: 3, ancestry: "#{@root.id}/#{@germany.id}/#{@berlin.id}")
end

describe "Mongestry" do

  before :all do
    Category.destroy_all
    initialize_country_tree
    Category.class_eval{ has_mongestry }
  end

  describe 'has_mongestry' do

    it 'should include instance methods into class where invoked' do
      class Foo
        include Mongoid::Document
        has_mongestry
      end

      [:build_ancestry, :ancestor_ids, :ancestors, :parent, :parent_id, :root, :root_id, :is_root?, :children, :child_ids, :has_children?, :is_childless?, :siblings, :sibling_ids, :has_siblings?, :is_only_child?, :descendants, :descendant_ids, :subtree, :subtree_ids, :depth, :parent_object].each do |method|
        Foo.new.respond_to?(method).should be_true
      end

    end

    it 'should include class methods into class where invoked' do
      class Bar
        include Mongoid::Document
        has_mongestry
      end

      [:roots, :ancestors_of, :children_of, :descendants_of, :subtree_of, :siblings_of, :before_depth, :to_depth, :at_depth, :from_depth, :after_depth].each do |method|
        Bar.respond_to?(method).should be_true
      end
    end
  end

  describe 'build_ancestry' do
    it 'should raise an error in case parent and parent_id were given'
    it 'should set the ancestry string'
    it 'should set persisted depth'
    it 'should not persist the parent object when given'
    it 'should not persist the parent_id when given'
  end

  describe 'ancestor_ids' do
    it 'should return the ancestor_ids of the given node' do
      ids = Category.where(name:"Pankow").first.ancestor_ids

      ids.size.should == 3
      ids.include?(@berlin.id).should  be_true
      ids.include?(@germany.id).should be_true
      ids.include?(@root.id).should    be_true
    end
  end

  describe 'ancestors' do
    it 'should return ancestors of the given node scoped' do
      ancestors = Category.where(name:"Pankow").first.ancestors.to_a

      ancestors.size.should == 3
      ancestors.include?(@berlin).should  be_true
      ancestors.include?(@germany).should be_true
      ancestors.include?(@root).should    be_true
    end
  end

  describe 'parent' do
    it 'should return the given nodes parent' do
      Category.where(name: "Germany").first.parent.first.should == @root
      Category.where(name: "Pankow").first.parent.first.should  == @berlin
      Category.roots.first.parent.should be_nil
    end
  end

  describe 'parent_id' do
    it 'should return the given nodes parents id' do
      Category.where(name: "Germany").first.parent_id.should == @root.id
      Category.where(name: "Pankow").first.parent_id.should  == @berlin.id
      Category.roots.first.parent_id.should be_nil
    end
  end

  describe 'root' do
    it 'should return the root of the tree of the given node' do
      Category.where(name: "Pankow").first.root.first.should  eql @root
      Category.where(name: "Berlin").first.root.first.should  eql @root
      Category.where(name: "Germany").first.root.first.should eql @root
      # #TODO
      # Category.where(name: "Root").first.root.first.should    eql @root
    end
  end

  describe 'root_id' do
    it 'should return the id of the root of the tre of the given node'
  end

  describe 'is_root?' do
    it 'should return true if given node is a root'
    it 'should return flase if given node is no root'
  end

  describe 'children' do
    it 'should return the given nodes children scoped'
  end

  describe 'child_ids' do
    it 'should return the given nodes childs ids'
  end

  describe 'has_children?' do
    it 'should return true if given node has children'
    it 'should return false if given node has no children'
  end

  describe 'is_childless?' do
    it 'should return true if given node has no children'
    it 'should return false if given node has children'
  end

  describe 'siblings' do
    it 'should return the given nodes siblings scoped'
  end

  describe 'sibling_ids' do
    it 'should return the given nodes siblings ids'
  end

  describe 'has_siblings?' do
    it 'should return true if given node has siblings'
    it 'should return false if given node has no siblings'
  end

  describe 'is_only_child?' do
    it 'should return true if given node has no siblings'
    it 'should return false if given node has siblings'
  end

  describe 'descendants' do
    it 'should return the given nodes descendants scoped'
  end

  describe 'descendant_ids' do
    it 'should return the given nodes descendants ids'
  end

  describe 'subtree' do
    it 'should return the given nodes subtree including the node itself'
  end

  describe 'subtree_ids' do
    it 'should return the ids of the given nodes subtree including the code itself'
  end

  describe 'depth' do
    it 'should return the computed depth of the given node'
  end

  describe 'parent_object' do
    it 'should return the correct object if object was given'
    it 'should return the correct object if object_id was given'
  end

  describe 'roots' do
    it 'should return all available roots scoped'
  end

  describe 'ancestors_of node' do
    it 'should return the given nodes ancestors scoped'
  end

  describe 'children_of node' do
    it 'should return the given nodes children scoped'
  end

  describe 'descendants_of node' do
    it 'should return the given nodes descendants scoped'
  end

  describe 'subtree_of node' do
    it 'should return the given nodes subtree scoped'
  end

  describe 'siblings_of node' do
    it 'should return the given nodes siblings scoped'
  end

  describe 'before_depth depth' do
    it 'should return a scope finding objects with a depth less than given depth'
  end

  describe 'to_depth depth' do
    it 'should return a scope finding objects with a depth less or equal than given depth'
  end

  describe 'at_depth depth' do
    it 'should return a scope finding objects with that exact given depth'
  end

  describe 'from_depth depth' do
    it 'should return a scope finding objects with a depth greater or equal than given depth'
  end

  describe 'after_depth depth' do
    it 'should return a scope finding objects with a depth greater than given depth'
  end

end
