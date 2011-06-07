require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mongestry" do

  before :each do
    Category.destroy_all
  end

  it 'should create some factory object' do
    Category.create(name: "blue")

    Category.count.should == 1
  end
end
