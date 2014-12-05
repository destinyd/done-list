class Target
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, type: String
  has_and_belongs_to_many :tasks
end
