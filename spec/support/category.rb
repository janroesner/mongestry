require 'mongestry'

class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :persisted_depth, type: Integer
  field :ancestry, type: String
end
