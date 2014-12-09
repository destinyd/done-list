class HomeController < ApplicationController
  def index
    if current_user
      redirect_to tasks_path
    else
      redirect_to new_user_session_path
    end
  end

  def dashboard
    @tasks_count = current_user.tasks.count
    @recent_tasks_count = current_user.tasks.where(:finished_at.gt => 30.days.ago).count

    @targets = Target.important.limit(5)
  end
end
