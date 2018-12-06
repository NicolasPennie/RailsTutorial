class UsersController < ApplicationController
  before_action :user_find, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  
  def new
    @user = User.new
  end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def show
    redirect_to root_url unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    if @user.destroy()
      flash[:success] = "#{@user.name} deleted"
    else
      flash[:error] = "#{@user.name} could not be deleted"
    end
    redirect_to users_url
  end
  
  def follow
  
  end
  
  def unfollow
    
  end
  
  private
  
    def user_find
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:danger] = "Sorry, that user does not exist."
        redirect_to root_url
      end
    end

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
end
