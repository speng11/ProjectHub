class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy,:user_graphs]
  before_action :authenticate, only: [:index, :show, :edit, :update, :destroy, :user_graphs]
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    puts user_params
    respond_to do |format|
      @user.check_password = true
      if @user.save
        require 'digest'
        md5 = Digest::MD5.new
        @user.check_password = false
        @user.password = md5.hexdigest @user.password
        @user.save
        format.html { redirect_to new_user_login_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_path(:id => @user.id), notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def user_graphs

  @user_name = @user.name

  @completed_tasks = Task.where(:assigned_to => @user.id , :state => "Completed")

  @in_progress_tasks =  Task.where(:assigned_to => @user.id , :state => "In Progress")

  # @open_tasks = Task.where(:assigned_to => @user.id , :state => "Open")

end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
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
        @user_notifications = @current_user.notifications.order(:id)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :is_admin, :password, :confirm_password, :email, :date_created, :avatar)
    end

end
