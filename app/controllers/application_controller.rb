class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def ensure_setting
    unless session['setting'].present?
      flash[:alert] = 'Set setting first before continue'
      redirect_to edit_setting_path
    end
  end
end
