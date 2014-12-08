class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, type: String
  field :finished_at, type: Time
  has_and_belongs_to_many :targets

  validates_presence_of :description
  validates_presence_of :finished_at

  def to_s
    description
  end
end
