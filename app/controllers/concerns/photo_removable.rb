module PhotoRemovable
  extend ActiveSupport::Concern

  private

  def update_with_photos(record, param_key, permitted_attributes)
    # Build update params excluding photos entirely to prevent Rails from clearing attachments
    update_params = params.require(param_key).permit(*permitted_attributes)
    new_photos = params.dig(param_key, :photos)&.reject(&:blank?)

    if record.update(update_params)
      # Only attach new photos if they were provided
      if new_photos&.any?
        record.photos.attach(new_photos)
      end

      remove_photos(record)
      true
    else
      false
    end
  end

  def remove_photos(record)
    return unless params[:remove_photos].present?

    record.photos.where(id: params[:remove_photos]).each(&:purge_later)
  end
end
