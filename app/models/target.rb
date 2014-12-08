class Target
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, type: String
  has_and_belongs_to_many :tasks

  validates_presence_of :description

  scope :recent, -> {order("id desc")}

  def to_s
    description
  end
end
