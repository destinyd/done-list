class LandingController < ApplicationController
  before_filter :authenticate_user!
  def first_login
    @tasks = current_user.tasks.recent
    render 'tasks/index'
  end
end
