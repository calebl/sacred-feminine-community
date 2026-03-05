class FaqsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_faq, only: [ :edit, :update, :destroy ]

  def index
    skip_authorization
    @faqs = policy_scope(Faq).active.ordered
    @new_faq = Faq.new if current_user.admin?
    render layout: false
  end

  def create
    @faq = Faq.new(faq_params)
    @faq.creator = current_user
    authorize @faq

    if @faq.save
      redirect_to faqs_path, notice: "FAQ created."
    else
      redirect_to faqs_path, alert: @faq.errors.full_messages.to_sentence
    end
  end

  def edit
    authorize @faq
  end

  def update
    authorize @faq
    if @faq.update(faq_params)
      redirect_to faqs_path, notice: "FAQ updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @faq
    @faq.destroy
    redirect_to faqs_path, notice: "FAQ deleted."
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer, :position, :active)
  end
end
