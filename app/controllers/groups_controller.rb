class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, only: [:index, :show, :edit, :update, :destroy, :new]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    token = params[:token]

    # use the user login instance and match emails to find current user
    @user_login = UserLogin.where(token: token).take
    @curr_user = User.where(email: @user_login.email).take

    respond_to do |format|
      if @group.save

        # create a new group membership for new group w/ current user as admin
        @new_membership = GroupMembership.create(group_id: @group.id, user_id: @curr_user.id, is_admin: true)

        # associate new membership with the group and the user
        @group.group_memberships << @new_membership
        @curr_user.group_memberships << @new_membership

        format.html { redirect_to group_path(:token => token, :id => @group.id), notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    @group = Group.new(group_params)
    token = params[:token]
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to group_path(:token => token, :id => @group.id), notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    def authenticate
      @user_login = UserLogin.where('token = (?)', params[:token]).take
      if @user_login == nil
        respond_to do |format|
          format.html { redirect_to new_user_login_path, notice: '' }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name)
    end
end