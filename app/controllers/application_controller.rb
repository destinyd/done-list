class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for resource
    unless current_user.is_mark? 'first login'
      current_user.mark 'first login'
      first_login_path
    else
      stored_location_for(resource) || super
    end
  end
end
