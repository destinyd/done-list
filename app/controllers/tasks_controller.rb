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
      redirect_to tasks_path
    else
      render :new
    end
  end

  def update
    @task.update(task_params)
    respond_with(@task)
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
