require 'mongestry'

class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  # has_mongestry

  field :name, type: String
  field :persisted_depth, type: Integer
  field :ancestry, type: String
end
