class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :user_system_status_notice

  def after_sign_in_path_for resource
    unless current_user.is_mark? 'first login'
      current_user.mark 'first login'
      first_login_path
    else
      stored_location_for(resource) || super
    end
  end

  def user_system_status_notice
    if current_user
      current_user.reload
      if current_user.system_status.length > 0
        flash[:notice] = [flash[:notice]]  if flash[:notice]
        flash[:notice] += current_user.system_status.map{|state| t("notice.system_status_#{state}")}
        current_user.update_attribute :system_status, []
      end
    end
  end
end
