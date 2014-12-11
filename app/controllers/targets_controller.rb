class TargetsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_target, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    current_user.learn '发现目标列表'
    @targets = current_user.targets.important
    respond_with(@targets)
  end

  def show
    respond_with(@target)
  end

  def new
    @target = current_user.targets.new
    respond_with(@target)
  end

  def edit
  end

  def create
    @target = current_user.targets.new(target_params)
    if @target.save
      current_user.learn '学会了创建<目标>'
      respond_with(@target)
    else
      render :new
    end
  end

  def update
    current_user.learn '学会了把<已完成任务>关联到<目标>' if target_params['task_ids'] and (@target.task_ids.length != target_params['task_ids'].select{|v| !v.blank?}.length)
    @target.update(target_params)
    respond_with(@target)
  end

  def destroy
    @target.destroy
    respond_with(@target)
  end

  private
    def set_target
      @target = current_user.targets.find(params[:id])
    end

    def target_params
      params.require(:target).permit(:description, task_ids: [])
    end
end
