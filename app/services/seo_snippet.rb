class SeoSnippet
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :label, :context, :type, :url, :logo, :same_url, :telephone, :contact_url,
    :contact_type, :area_served, :available_language, :facebook_url, :twitter_url, :google_plus_url, :instagram_url,
    :pinterest_url, :linkedin_url, :youtube_url

  validates :url, :label, presence: true
  validates :telephone, format: { with: /\A\+?[\d*| *|\-]+\z/ ,
      message: "only allows letters"}
end
