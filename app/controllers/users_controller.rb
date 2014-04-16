class UsersController < ApplicationController
  before_action :require_user, only: [:show]  
  def new
    redirect_to :home if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params) 
    if @user.save
      handle_invitation
      StripeWrapper.set_api_key

      StripeWrapper::Charge.create(
        :amount => 999,
        :card => params[:stripeToken], 
        :description => "Charge for MyFlix Subscription, #{@user.email}"
        )
      AppMailer.delay.send_welcome_email(@user.id)
      redirect_to :sign_in
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new_with_invitation_token
    invitation = Invitation.where(token: params[:token]).first
    if invitation
      @user = User.new(email: invitation.recipient_email)
      @invitation_token = invitation.token
      render :new
    else 
      redirect_to :expired_token
    end

  end

  private

  def handle_invitation
    if params[:invitation_token].present?
      invitation = Invitation.where(token: params[:invitation_token]).first
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      invitation.update_column(:token, nil)
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :full_name)
  end

end