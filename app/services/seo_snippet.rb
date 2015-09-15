class SeoSnippet
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :label, :context, :type, :url, :logo, :telephone, :contact_url,
    :contact_type, :area_served, :available_language, :facebook_url, :twitter_url, :google_plus_url, :instagram_url,
    :pinterest_url, :linkedin_url, :youtube_url, :contact_type_selected

  validates :url, :label, presence: true
  validates :contact_type, absence: true
  validates :telephone,
      format: { with: /\A\+?[\d*| *|\-]+\z/,
      message: "only allows numbers"},
      presence: true, if: Proc.new{|u| u.contact_type_selected }
  validates :telephone,
      absence: true, unless: Proc.new{|u| u.contact_type_selected }
end
