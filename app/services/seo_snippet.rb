class SeoSnippet
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :context, :type, :url, :logo, :same_url, :telephone, 
    :contact_type, :area_served, :available_language, :facebook_url, :twitter_url, :google_plus_url, :instagram_url,
    :pinterest_url, :linkedin_url, :youtube_url

  validates :url, presence: true

  def initialize(attributes = {})
    @attributes = attributes
  end
end
