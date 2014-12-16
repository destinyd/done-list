class TasksController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @tasks = current_user.tasks.recent
    respond_with(@tasks)
  end

  def new
    @task = current_user.tasks.new
    respond_with(@task)
  end

  def edit
  end

  def create
    @task = current_user.tasks.new(task_params)
    if @task.save
      current_user.learn '学会了创建<已完成任务>'
      flash[:notice] = '没有为任务指定目标，自动归为【随手记录一些已完成任务】' if @task.has_not_targets
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def update
    current_user.learn '学会了把<已完成任务>关联到<目标>' if task_params['target_ids'] and (@task.target_ids.length != task_params['target_ids'].select{|v| !v.blank?}.length)
    if @task.update(task_params)
      redirect_to tasks_path
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    respond_with(@task)
  end

  private
    def set_task
      @task = current_user.tasks.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:description, :finished_at, target_ids: [])
    end
end
