class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  field :description, type: String
  field :finished_at, type: Time, default: -> {Time.now}
  belongs_to :user
  has_and_belongs_to_many :targets

  validates_presence_of :description
  validates_presence_of :finished_at

  scope :recent, -> {desc(:finished_at)}
  scope :month, -> {where(:finished_at.gt => 30.days.ago).asc(:finished_at)}

  def to_s
    description
  end

  after_create :add_default_target, unless: :targets?
  after_update :add_default_target, unless: :targets?
  def add_default_target
    if @default_target = self.user.targets.where(is_default: true).first
      self.targets << @default_target
    end
  end

  after_create :refresh_targets_tasks_count
  after_update :refresh_targets_tasks_count
  def refresh_targets_tasks_count
    if self.changes['target_ids']
      new_ids = self.changes['target_ids'].first.nil? ? self.changes['target_ids'].last : (self.changes['target_ids'].last - self.changes['target_ids'].first)
      Target.find(new_ids).each{|target| target.inc(tasks_count: 1)} unless new_ids.blank?
      unless self.changes['target_ids'].first.blank?
        old_ids = self.changes['target_ids'].first - self.changes['target_ids'].last
        Target.find(old_ids).each{|target| target.inc(tasks_count: -1)} unless old_ids.blank?
      end
    end
  end

  after_destroy :dec_targets_tasks_count
  def dec_targets_tasks_count
    self.targets.each do |target|
      target.inc tasks_count: -1
    end
  end
end
