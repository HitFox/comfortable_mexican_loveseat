module Redirectify
  extend ActiveSupport::Concern

  included do
    helper_method :back_or_default_path
  end

  def back_or_default_path(default_path)
    referer_path || default_path
  end

  def referer_path
    return if request.referer.blank?

    routing_hash = Rails.application.routes.recognize_path(request.referer)
    referer_uri = request.referer.dup.delete(['?', URI.parse(request.referer).query].join)

    request.referer if url_for(routing_hash) == referer_uri
  rescue
    nil
  end
end
