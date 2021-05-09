class ApplicationController < ActionController::Base
  before_action :require_login

  helper_method :current_users_list

  private

  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end

  def current_users_list
    current_users = User.all.select { |user| user.online? }
    current_users.map { |user| user.email }.join(", ")
  end
end
