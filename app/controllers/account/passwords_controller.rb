module Account
  class PasswordsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user

    def edit
      authorize [ :account, @user ], :update_password?
    end

    def update
      authorize [ :account, @user ], :update_password?

      unless @user.valid_password?(params[:user][:current_password])
        @user.errors.add(:current_password, "is incorrect")
        render :edit, status: :unprocessable_entity
        return
      end

      if @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
        bypass_sign_in(@user)
        redirect_to edit_profile_path(@user), notice: "Password updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = current_user
    end
  end
end
