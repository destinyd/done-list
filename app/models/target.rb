class Target
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, type: String
  field :tasks_count, type: Integer, default: 0
  field :is_default, type: Boolean, default: false
  field :is_system, type: Boolean, default: false
  belongs_to :user
  has_and_belongs_to_many :tasks

  validates_presence_of :description

  scope :recent, -> {desc(:id)}
  scope :important, -> {desc(:tasks_count)}

  index({ tasks_count: 1 }, { background: true })
  index({ user_id: 1 }, { background: true })
  index({ is_default: 1 }, { background: true })
  index({ is_system: 1 }, { background: true })

  def to_s
    description
  end

  before_create :refresh_tasks_count
  before_update :refresh_tasks_count
  def refresh_tasks_count
    self.tasks_count = self.tasks.count
  end
end
