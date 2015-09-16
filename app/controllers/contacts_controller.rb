class ContactsController < ApplicationController
  before_action :ensure_setting

  def index
    @contacts = Contact.all
  end

  def import_all
    Contact.import_all(session[:setting], 1000)
    flash[:success] = "Contact import_all job scheduled"
    redirect_to root_path
  end

  def export
    @contacts = Contact.all
    respond_to do |format| 
       format.xlsx {render xlsx: 'export', filename: "payments.xlsx", layout: false}
    end
  end

end