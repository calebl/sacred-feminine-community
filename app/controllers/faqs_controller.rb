class FaqsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_faq, only: [ :edit, :update, :destroy ]

  def create
    @faq = Faq.new(faq_params)
    @faq.creator = current_user
    authorize @faq

    if @faq.save
      redirect_to authenticated_root_path(tab: "faqs"), notice: "FAQ created."
    else
      redirect_to authenticated_root_path(tab: "faqs"), alert: @faq.errors.full_messages.to_sentence
    end
  end

  def edit
    authorize @faq
  end

  def update
    authorize @faq
    if @faq.update(faq_params)
      redirect_to authenticated_root_path(tab: "faqs"), notice: "FAQ updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @faq
    @faq.destroy
    redirect_to authenticated_root_path(tab: "faqs"), notice: "FAQ deleted."
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer, :position, :active)
  end
end
