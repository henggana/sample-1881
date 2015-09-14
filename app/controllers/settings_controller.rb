class SettingsController < ApplicationController
  def edit
    if session[:setting].present?
      @setting = SettingForm.new(session[:setting])
    else
      @setting = SettingForm.new
    end
  end

  def update
    @setting = SettingForm.new(setting_params)
    if @setting.valid?
      session[:setting] = @setting.attributes
      flash[:success] = 'Setting saved sucessfully!'
      redirect_to root_path
    else
      flash[:alert] = 'Failed to save. Please check your inputs!'
      render :edit
    end
  end

  protected

  def setting_params
    params.require(:setting_form).permit(
      :smspay_user, :smspay_password, :smspay_base_url, 
      :catalog_user, :catalog_msisdn, :catalog_password)
  end
end