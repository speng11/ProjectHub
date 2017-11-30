class GroupNotificationsController < ApplicationController
  before_action :authenticate, only: [:index, :show, :edit, :update, :destroy, :new, :process_leave_grp]
  before_action :get_notifications
  def index
    @all_group_notifications = Group.find(params[:group_id]).group_notifications
    @group = Group.find(params[:group_id])
  end

  def authenticate
    token = session[:current_user_token]
    @user_login = UserLogin.where('token = (?)', token).take
    if @user_login == nil
      respond_to do |format|
        format.html { redirect_to new_user_login_path, notice: '' }
      end
    else
      @current_user = User.where(:email => @user_login.email).take
      @user_notifications = @current_user.notifications
    end
  end
end
