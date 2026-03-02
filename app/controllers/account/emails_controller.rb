module Account
  class EmailsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user

    def edit
      authorize [ :account, @user ], :update_email?
    end

    def update
      authorize [ :account, @user ], :update_email?

      unless @user.valid_password?(params[:user][:current_password])
        @user.errors.add(:current_password, "is incorrect")
        render :edit, status: :unprocessable_entity
        return
      end

      if @user.update(email: params[:user][:email])
        redirect_to edit_account_email_path, notice: "Email updated successfully."
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
