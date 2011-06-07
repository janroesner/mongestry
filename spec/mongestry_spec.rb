require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def initialize_country_tree
  root        = Category.create(name: "Root",        persisted_depth: 0)
  germany     = Category.create(name: "Germany",     persisted_depth: 1, ancestry: "#{root.id}")
  switzerland = Category.create(name: "Switzerland", persisted_depth: 1, ancestry: "#{root.id}")
  austria     = Category.create(name: "Austria",     persisted_depth: 1, ancestry: "#{root.id}")
  berlin      = Category.create(name: "Berlin",      persisted_depth: 2, ancestry: "#{root.id}/#{germany.id}")
  munich      = Category.create(name: "Munich",      persisted_depth: 2, ancestry: "#{root.id}/#{germany.id}")
  hamburg     = Category.create(name: "Hamburg",     persisted_depth: 2, ancestry: "#{root.id}/#{germany.id}")
  bern        = Category.create(name: "Bern",        persisted_depth: 2, ancestry: "#{root.id}/#{switzerland.id}")
  zurich      = Category.create(name: "Zurich",      persisted_depth: 2, ancestry: "#{root.id}/#{switzerland.id}")
  vienna      = Category.create(name: "Vienna",      persisted_depth: 2, ancestry: "#{root.id}/#{austria.id}")
  graz        = Category.create(name: "Graz",        persisted_depth: 2, ancestry: "#{root.id}/#{austria.id}")
  pankow      = Category.create(name: "Pankow",      persisted_depth: 3, ancestry: "#{root.id}/#{germany.id}/#{berlin.id}")
end

describe "Mongestry" do

  before :all do
    Category.destroy_all
    initialize_country_tree
  end

  it 'should create some factory object' do
    Category.create(name: "blue")

    Category.count.should == 13
  end
end
