class SeoSnippet
  extend ActiveModel::Naming

  attr_accessor :context, :type, :url, :logo, :same_url, :telephone, 
    :contact_type, :facebook_url, :twitter_url, :google_plus_url, :instagram_url,
    :pinterest_url, :linkedin_url, :youtube_url

  def initialize
  end
end
