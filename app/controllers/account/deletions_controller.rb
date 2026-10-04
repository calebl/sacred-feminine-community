module Account
  class DeletionsController < ApplicationController
    CONFIRMATION_WORD = "DELETE"

    before_action :authenticate_user!
    before_action :set_user

    def new
      authorize [ :account, @user ], :destroy_account?
    end

    def create
      authorize [ :account, @user ], :destroy_account?

      if impersonating?
        redirect_to new_account_deletion_path, alert: "Stop impersonating before deleting an account."
        return
      end

      unless @user.valid_password?(params.dig(:user, :current_password))
        @user.errors.add(:current_password, "is incorrect")
      end
      unless params.dig(:user, :confirmation).to_s.strip == CONFIRMATION_WORD
        @user.errors.add(:base, "Type #{CONFIRMATION_WORD} to confirm")
      end
      if @user.errors.any?
        render :new, status: :unprocessable_entity
        return
      end

      @user.destroy_account!
      sign_out(@user)
      redirect_to new_user_session_path, notice: "Your account and everything you shared have been permanently deleted."
    rescue ActiveRecord::RecordNotDestroyed => e
      redirect_to new_account_deletion_path, alert: e.message
    end

    private

    def set_user
      @user = current_user
    end
  end
end
