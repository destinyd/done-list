# encoding: utf-8

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:weibo]

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  field :uid,    type: String
  field :nickname,    type: String

  field :system_status, type: Array, default: []

  has_many :tasks
  has_many :targets
  embeds_many :learns


  # https://github.com/mongoid/mongoid/issues/3626#issuecomment-64700154
  def self.serialize_from_session(key, salt)
    (key = key.first) if key.kind_of? Array
    (key = BSON::ObjectId.from_string(key['$oid'])) if key.kind_of? Hash

    record = to_adapter.get(key)
    record if record && record.authenticatable_salt == salt
  end

  def self.serialize_into_session(record)
    [record.id.to_s, record.authenticatable_salt]
  end

  has_many :user_tokens

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session[:omniauth]
        user.user_tokens.build(:provider => data['provider'], :uid => data['uid'])
      end
    end
  end

  def apply_omniauth(omniauth)
    #add some info about the user
    #self.name = omniauth['user_info']['name'] if name.blank?
    #self.nickname = omniauth['user_info']['nickname'] if nickname.blank?

    unless omniauth['credentials'].blank?
      user_tokens.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
      #user_tokens.build(:provider => omniauth['provider'], 
      #                  :uid => omniauth['uid'],
      #                  :token => omniauth['credentials']['token'], 
      #                  :secret => omniauth['credentials']['secret'])
    else
      user_tokens.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
    end
    #self.confirm!# unless user.email.blank?
  end

  def password_required?
    false
  end

  def email_required?
    false
  end

  def star_targets_hash
    max_count = self.targets.important.first.try(:tasks_count) || 0
    min_count = self.targets.important.last.try(:tasks_count) || 0
    if min_count == max_count
      if min_count > 0
        @star_targets_hash = {4 => self.targets.important.to_a}
      else
        @star_targets_hash = {}
      end
    else
      delta = (max_count - min_count) / 5.0
      @star_targets_hash = self.targets.important.group_by do |target|
        v = ((target.tasks_count - min_count) / delta).floor
        v > 4 ? 4 : v
      end
    end
  end

  def is_learn? key
    self.learns.where(key: key).first
  end

  def get_gtd
    @gtd ||= self.targets.where(description: '提升 GTD 水平').first
  end

  def is_mark? description
    self.learns.where(key: description).first
  end

  def mark description
    self.learns.where(key: description).first_or_create
  end

  def learn description
    unless is_learn? description
      mark description
      task = self.tasks.create description: description, targets: [get_gtd]
      task.targets << get_gtd
      task.save
    end
  end

  def push_status param
    if param.is_a?(String)
      self.system_status << param
      self.save
    elsif param.is_a?(Array)
      self.system_status + param
      self.save
    end
  end

  after_create :add_default_data
  def add_default_data
    target = self.targets.create description: '提升 GTD 水平', is_system: true
    task = self.tasks.create description: '开始使用 Done List', finished_at: Time.now
    target.tasks << task
    target = self.targets.create description: '随手记录一些已完成任务', is_default: true, is_system: true
    self.learn '发现任务列表'
    self.system_status << '001'
    self.system_status << '002'
    self.system_status << '003'
    self.save
  end
end
