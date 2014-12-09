class Target
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, type: String
  field :tasks_count, type: Integer, default: 0
  has_and_belongs_to_many :tasks

  validates_presence_of :description

  scope :recent, -> {order("id desc")}
  scope :important, -> {order("tasks_count desc")}

  def to_s
    description
  end

  before_create :refresh_tasks_count
  before_update :refresh_tasks_count
  def refresh_tasks_count
    self.tasks_count = self.tasks.count
  end
end
