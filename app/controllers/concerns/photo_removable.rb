module PhotoRemovable
  extend ActiveSupport::Concern

  private

  def remove_photos(record)
    return unless params[:remove_photos].present?

    record.photos.where(id: params[:remove_photos]).each(&:purge_later)
  end
end
