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
  context "with fixed tree" do

    before :all do
      Category.destroy_all
      initialize_country_tree
      Category.class_eval{ has_mongestry }
    end

    describe '#has_mongestry' do

      it 'should include instance methods into class where invoked' do
        class Foo
          include Mongoid::Document
          has_mongestry
        end

        [:build_ancestry, :ancestor_ids, :ancestors, :parent, :parent_id, :root, :root_id, :is_root?, :children, :child_ids, :has_children?, :is_childless?, :siblings, :sibling_ids, :has_siblings?, :is_only_child?, :descendants, :descendant_ids, :subtree, :subtree_ids, :depth].each do |method|
          Foo.new.respond_to?(method).should be_true
        end

      end

      it 'should include class methods into class where invoked' do
        class Bar
          include Mongoid::Document
          has_mongestry
        end

        [:roots, :ancestors_of, :children_of, :descendants_of, :subtree_of, :siblings_of, :before_depth, :to_depth, :at_depth, :from_depth, :after_depth, :object_for].each do |method|
          Bar.respond_to?(method).should be_true
        end
      end
    end

    describe '#ancestor_ids' do
      it 'should return the ancestor_ids of the given node' do
        ids = Category.where(name:"Pankow").first.ancestor_ids

        ids.size.should == 3
        ids.include?(@berlin.id).should  be_true
        ids.include?(@germany.id).should be_true
        ids.include?(@root.id).should    be_true
      end
    end

    describe '#ancestors' do
      it 'should return ancestors of the given node scoped' do
        ancestors = Category.where(name:"Pankow").first.ancestors.to_a

        ancestors.size.should == 3
        ancestors.include?(@berlin).should  be_true
        ancestors.include?(@germany).should be_true
        ancestors.include?(@root).should    be_true
      end

      it 'should return an empty array if called on a root category' do
        ancestors = Category.where(name: "Root").first.ancestors.to_a
        ancestors.size.should == 0
      end
    end

    describe '#parent' do
      it 'should return the given nodes parent' do
        Category.where(name: "Germany").first.parent.should == @root
        Category.where(name: "Pankow").first.parent.should  == @berlin
        Category.roots.first.parent.should be_nil
      end
    end

    describe '#parent_id' do
      it 'should return the given nodes parents id' do
        Category.where(name: "Germany").first.parent_id.should == @root.id
        Category.where(name: "Pankow").first.parent_id.should  == @berlin.id
        Category.roots.first.parent_id.should be_nil
      end
    end

    describe '#root' do
      it 'should return the root of the tree of the given node' do
        Category.where(name: "Pankow").first.root.should  eql @root
        Category.where(name: "Berlin").first.root.should  eql @root
        Category.where(name: "Germany").first.root.should eql @root
        Category.where(name: "Root").first.root.should    eql @root
      end
    end

    describe '#root_id' do
      it 'should return the id of the root of the tree of the given node' do
        Category.where(name: "Pankow").first.root_id.should  eql @root.id
        Category.where(name: "Berlin").first.root_id.should  eql @root.id
        Category.where(name: "Germany").first.root_id.should eql @root.id
        Category.where(name: "Root").first.root_id.should    eql @root.id
      end
    end

    describe '#is_root?' do
      it 'should return true if given node is a root' do
        Category.where(name: "Root").first.is_root?.should be_true
      end
      it 'should return false if given node is no root' do
        Category.where(name: "Pankow").first.is_root?.should  be_false
        Category.where(name: "Germany").first.is_root?.should be_false
        Category.where(name: "Berlin").first.is_root?.should  be_false
        Category.where(name: "Bern").first.is_root?.should    be_false
      end
    end

    describe '#children' do
      it 'should return the given nodes children scoped' do
        children_scope = Category.where(name: "Germany").first.children
        children_scope.is_a?(Mongoid::Criteria).should     be_true
        children_scope.count.should                        == 3
        children_scope.to_a.include?(@berlin).should       be_true
        children_scope.to_a.include?(@hamburg).should      be_true
        children_scope.to_a.include?(@munich).should       be_true
      end
    end

    describe '#child_ids' do
      it 'should return the given nodes childs ids' do
        ids = Category.where(name: "Germany").first.child_ids
        ids.count.should                      == 3
        ids.include?(@berlin.id).should       be_true
        ids.include?(@hamburg.id).should      be_true
        ids.include?(@munich.id).should       be_true
      end
    end

    describe '#has_children?' do
      it 'should return true if given node has children' do
        Category.where(name: "Root").first.has_children?.should    be_true
        Category.where(name: "Germany").first.has_children?.should be_true
        Category.where(name: "Berlin").first.has_children?.should  be_true
      end
      it 'should return false if given node has no children' do
        Category.where(name: "Pankow").first.has_children?.should be_false
        Category.where(name: "Bern").first.has_children?.should   be_false
        Category.where(name: "Zurich").first.has_children?.should be_false
      end
    end

    describe '#is_childless?' do
      it 'should return true if given node has no children' do
        Category.where(name: "Root").first.is_childless?.should    be_false
        Category.where(name: "Germany").first.is_childless?.should be_false
        Category.where(name: "Berlin").first.is_childless?.should  be_false
      end
      it 'should return false if given node has children' do
        Category.where(name: "Pankow").first.is_childless?.should be_true
        Category.where(name: "Bern").first.is_childless?.should   be_true
        Category.where(name: "Zurich").first.is_childless?.should be_true
      end
    end

    describe '#siblings' do
      it 'should return the given nodes siblings scoped' do
        siblings_scope = Category.where(name: "Berlin").first.siblings
        siblings_scope.is_a?(Mongoid::Criteria).should be_true
        siblings_scope.to_a.size.should == 2
        siblings_scope.to_a.include?(@hamburg).should  be_true
        siblings_scope.to_a.include?(@munich).should   be_true
      end
    end

    describe '#sibling_ids' do
      it 'should return the given nodes siblings ids' do
        ids = Category.where(name: "Berlin").first.sibling_ids
        ids.size.should == 2
        ids.include?(@hamburg.id).should  be_true
        ids.include?(@munich.id).should   be_true
      end
    end

    describe '#has_siblings?' do
      it 'should return true if given node has siblings' do
        Category.where(name: "Berlin").first.has_siblings?.should  be_true
        Category.where(name: "Bern").first.has_siblings?.should    be_true
        Category.where(name: "Germany").first.has_siblings?.should be_true
      end
      it 'should return false if given node has no siblings' do
        Category.where(name: "Root").first.has_siblings?.should   be_false
        Category.where(name: "Pankow").first.has_siblings?.should be_false
      end
    end

    describe '#is_only_child?' do
      it 'should return true if given node has no siblings' do
        Category.where(name: "Berlin").first.is_only_child?.should  be_false
        Category.where(name: "Bern").first.is_only_child?.should    be_false
        Category.where(name: "Germany").first.is_only_child?.should be_false
      end
      it 'should return false if given node has siblings' do
        Category.where(name: "Root").first.is_only_child?.should   be_true
        Category.where(name: "Pankow").first.is_only_child?.should be_true
      end
    end

    describe '#descendants' do
      it 'should return the given nodes descendants scoped' do
        desc_scope = Category.where(name: "Germany").first.descendants
        desc_scope.is_a?(Mongoid::Criteria).should be_true
        desc_scope.to_a.size.should == 4
        desc_scope.to_a.include?(@berlin).should   be_true
        desc_scope.to_a.include?(@hamburg).should  be_true
        desc_scope.to_a.include?(@munich).should   be_true
        desc_scope.to_a.include?(@pankow).should   be_true
      end
    end

    describe '#descendant_ids' do
      it 'should return the given nodes descendants ids' do
        ids = Category.where(name: "Germany").first.descendant_ids
        ids.size.should == 4
        ids.include?(@berlin.id).should   be_true
        ids.include?(@hamburg.id).should  be_true
        ids.include?(@munich.id).should   be_true
        ids.include?(@pankow.id).should   be_true
      end
    end

    describe '#subtree' do
      it 'should return the given nodes subtree including the node itself' do
        subtree_scope = Category.where(name: "Germany").first.subtree
        subtree_scope.is_a?(Mongoid::Criteria).should be_true
        subtree_scope.to_a.size.should == 5
        subtree_scope.to_a.include?(@germany).should  be_true
        subtree_scope.to_a.include?(@berlin).should   be_true
        subtree_scope.to_a.include?(@hamburg).should  be_true
        subtree_scope.to_a.include?(@munich).should   be_true
        subtree_scope.to_a.include?(@pankow).should   be_true
      end
    end

    describe '#subtree_ids' do
      it 'should return the ids of the given nodes subtree including the code itself' do
        ids = Category.where(name: "Germany").first.subtree_ids
        ids.size.should == 5
        ids.include?(@germany.id).should  be_true
        ids.include?(@berlin.id).should   be_true
        ids.include?(@hamburg.id).should  be_true
        ids.include?(@munich.id).should   be_true
        ids.include?(@pankow.id).should   be_true
      end
    end

    describe '#depth' do
      it 'should return the computed depth of the given node' do
        Category.all.each do |category|
          category.depth.should == category.persisted_depth
        end
      end
    end

    describe '#object_for' do
      it 'should return the correct object if object was given' do
        Category.object_for(Category.where(name: "Berlin").first).should      == @berlin
        Category.object_for(Category.where(name: "Germany").first).should     == @germany
        Category.object_for(Category.where(name: "Root").first).should        == @root
      end
      it 'should return the correct object if object_id was given as BSON::ObjectId' do
        Category.object_for(Category.where(name: "Berlin").first.id).should      == @berlin
        Category.object_for(Category.where(name: "Germany").first.id).should     == @germany
        Category.object_for(Category.where(name: "Root").first.id).should        == @root
      end
      it 'should return the correct object if object_id was given as String' do
        Category.object_for(Category.where(name: "Berlin").first.id.to_s).should      == @berlin
        Category.object_for(Category.where(name: "Germany").first.id.to_s).should     == @germany
        Category.object_for(Category.where(name: "Root").first.id.to_s).should        == @root
      end
    end

    describe '#roots' do
      it 'should return all available roots scoped' do
        roots_scope = Category.roots
        roots_scope.is_a?(Mongoid::Criteria).should be_true
        roots_scope.to_a.size.should == 1
        roots_scope.to_a.include?(@root).should be_true
      end
    end

    describe '#ancestors_of node' do
      it 'should return the given nodes ancestors scoped' do
        anc_scope = Category.ancestors_of(Category.where(name: "Pankow").first)
        anc_scope.is_a?(Mongoid::Criteria).should be_true
        anc_scope.to_a.size.should == 3
        anc_scope.to_a.include?(@berlin).should   be_true
        anc_scope.to_a.include?(@germany).should  be_true
        anc_scope.to_a.include?(@root).should     be_true
      end
    end

    describe '#children_of node' do
      it 'should return the given nodes children scoped' do
        child_scope = Category.children_of(Category.where(name: "Germany").first)
        child_scope.is_a?(Mongoid::Criteria).should be_true
        child_scope.to_a.size.should == 3
        child_scope.to_a.include?(@berlin).should   be_true
        child_scope.to_a.include?(@hamburg).should  be_true
        child_scope.to_a.include?(@munich).should   be_true
      end
    end

    describe '#descendants_of node' do
      it 'should return the given nodes descendants scoped' do
        desc_scope = Category.descendants_of(Category.where(name: "Germany").first)
        desc_scope.is_a?(Mongoid::Criteria).should be_true
        desc_scope.to_a.size.should == 4
        desc_scope.to_a.include?(@berlin).should   be_true
        desc_scope.to_a.include?(@munich).should   be_true
        desc_scope.to_a.include?(@hamburg).should  be_true
        desc_scope.to_a.include?(@pankow).should   be_true
      end
    end

    describe '#subtree_of node' do
      it 'should return the given nodes subtree scoped' do
        subtree_scope = Category.subtree_of(Category.where(name: "Germany").first)
        subtree_scope.is_a?(Mongoid::Criteria).should be_true
        subtree_scope.to_a.size.should == 5
        subtree_scope.to_a.include?(@germany).should  be_true
        subtree_scope.to_a.include?(@berlin).should   be_true
        subtree_scope.to_a.include?(@munich).should   be_true
        subtree_scope.to_a.include?(@hamburg).should  be_true
        subtree_scope.to_a.include?(@pankow).should   be_true
      end
    end

    describe '#siblings_of node' do
      it 'should return the given nodes siblings scoped' do
        siblings_scope = Category.siblings_of(Category.where(name: "Berlin").first)
        siblings_scope.is_a?(Mongoid::Criteria).should be_true
        siblings_scope.to_a.size.should == 2
        siblings_scope.to_a.include?(@hamburg).should  be_true
        siblings_scope.to_a.include?(@munich).should   be_true
      end
    end

    describe '#before_depth depth' do
      it 'should return a scope finding objects with a depth less than given depth' do
        amounts = { 0 => 0, 1 => 1, 2 => 4, 3 => 11, 4 => 12 }
        0.upto(3) do |depth|
          Category.before_depth(depth).size.should == amounts[depth]
          Category.before_depth(depth).each do |category|
            category.persisted_depth.should < depth
          end
        end
      end
    end

    describe '#to_depth depth' do
      it 'should return a scope finding objects with a depth less or equal than given depth' do
        amounts = { 0 => 1, 1 => 4, 2 => 11, 3 => 12 }
        0.upto(3) do |depth|
          Category.to_depth(depth).size.should == amounts[depth]
          Category.before_depth(depth).each do |category|
            category.persisted_depth.should <= depth
          end
        end
      end
    end

    describe '#at_depth depth' do
      it 'should return a scope finding objects with that exact given depth' do
        amounts = { 0 => 1, 1 => 3, 2 => 7, 3 => 1 }
        0.upto(3) do |depth|
          Category.at_depth(depth).size.should == amounts[depth]
          Category.at_depth(depth).each do |category|
            category.persisted_depth.should == depth
          end
        end
      end
    end

    describe '#from_depth depth' do
      it 'should return a scope finding objects with a depth greater or equal than given depth' do
        amounts = { 0 => 12, 1 => 11, 2 => 8, 3 => 1 }
        0.upto(3) do |depth|
          Category.from_depth(depth).size.should == amounts[depth]
          Category.from_depth(depth).each do |category|
            category.persisted_depth.should >= depth
          end
        end
      end
    end

    describe '#after_depth depth' do
      it 'should return a scope finding objects with a depth greater than given depth' do
        amounts = { 0 => 11, 1 => 8, 2 => 1, 3 => 0 }
        0.upto(3) do |depth|
          Category.after_depth(depth).size.should == amounts[depth]
          Category.after_depth(depth).each do |category|
            category.persisted_depth.should > depth
          end
        end
      end
    end
  end

  context "with new nodes" do
    describe '#build_ancestry' do
      it 'should raise an error in case parent and parent_id were given' do
        lambda{ Category.create(name: "Error", parent: Category.first, parent_id: Category.first.id) }.should raise_error "Either parent or parent_id can be given, not both at once"
      end

      it 'should set the ancestry string' do
        category = Category.create!(name: "Correct country", parent: Category.where(name: "Root").first)
        category.reload.ancestry.should == Category.where(name: "Root").first.id.to_s
        category = Category.create!(name: "Correct country2", parent_id: Category.where(name: "Root").first.id)
        category.reload.ancestry.should == Category.where(name: "Root").first.id.to_s
      end

      it 'should set persisted depth' do
        category = Category.create!(name: "Depth test", parent: Category.where(name: "Pankow").first)
        category.reload.persisted_depth.should == 4
        category = Category.create!(name: "Depth test2", parent: Category.where(name: "Root").first)
        category.reload.persisted_depth.should == 1
      end

      it 'should not persist the parent object when given' do
        category = Category.create!(name: "Persistence test", parent: Category.where(name: "Root").first)
        category.reload.attributes.keys.include?(:parent).should be_false
      end
      it 'should not persist the parent_id when given' do
        category = Category.create!(name: "Persistence test2", parent: Category.where(name: "Root").first)
        category.reload.attributes.keys.include?(:parent_id).should be_false
      end
    end
  end
end
