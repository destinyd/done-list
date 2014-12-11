class Learn
  include Mongoid::Document
  include Mongoid::Timestamps
  field :key, type: String
  field :is_learn, type: Mongoid::Boolean, default: true
  embedded_in :user
end
