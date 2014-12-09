class TargetsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_target, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
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
    @target.save
    respond_with(@target)
  end

  def update
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
