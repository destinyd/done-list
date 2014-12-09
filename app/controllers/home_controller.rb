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
    @recent_tasks = current_user.tasks.where(:finished_at.gt => 30.days.ago)
    @recent_tasks_count = @recent_tasks.count
    @targets = Target.important.limit(5)
    @date_tasks_hash = @recent_tasks.group_by{|t| t.finished_at.strftime("%Y-%m-%d")}
    @color_num = 3312336
  end
end
