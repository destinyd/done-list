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
    @date_tasks_hash = @recent_tasks.group_by{|t| t.finished_at.strftime("%Y-%m-%d")}
    @color_num = 3312336
    max_count = current_user.targets.important.first.tasks_count
    min_count = current_user.targets.important.last.tasks_count
    max_count -= 0.001 if max_count > min_count
    delta = (max_count - min_count) / 5.0
    @star_targets_hash = current_user.targets.important.group_by do |target|
      v = (target.tasks_count / delta).floor
      v > 4 ? 4 : v
    end
  end
end
