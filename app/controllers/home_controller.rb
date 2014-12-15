class HomeController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard]
  def index
    if current_user
      redirect_to tasks_path
    else
      redirect_to new_user_session_path
    end
  end

  def dashboard
    current_user.learn '发现完成状况统计图'
    @tasks_count = current_user.tasks.count
    @recent_tasks = current_user.tasks.five_day
    @recent_tasks_count = @recent_tasks.count
    @targets = current_user.targets.important.limit(5).to_a
    @date_tasks_hash = @recent_tasks.group_by{|t| t.finished_at.strftime("%Y-%m-%d")}
    @color_num = 3312336
  end
end
