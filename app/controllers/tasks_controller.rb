class TasksController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @tasks = current_user.tasks.recent
    respond_with(@tasks)
  end

  def new
    if params[:task]
      @task = current_user.tasks.new task_params
    else
      @task = current_user.tasks.new
    end
    respond_with(@task)
  end

  def edit
  end

  def create
    @task = current_user.tasks.new(task_params)
    if @task.save
      flash[:notice] = []
      if current_user.learn '学会了创建<已完成任务>'
        flash[:notice] << t('notice.system_status_006')
      end
      if @task.has_not_targets
        flash[:notice] << t('notice.system_status_008')
      end
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def update
    if task_params['target_ids'] and (@task.target_ids.length != task_params['target_ids'].select{|v| !v.blank?}.length)
      flash[:notice] = t('notice.system_status_007') if current_user.learn '学会了把<已完成任务>关联到<目标>'
    end
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
