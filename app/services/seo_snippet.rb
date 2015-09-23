class SeoSnippet
  include ActiveModel::Model
  # include ActiveModel::Validations
  extend ActiveModel::Naming

  DEFAULT_PARAMS = {
    "corporate_contacts_attributes" => {"0" => {}},
    "label" => "seo snippet",
    "context" => "http://schema.org",
    "type" => "Organization"
  }

  attr_accessor :label, :context, :type, :url, :logo, :facebook_url, :twitter_url, :google_plus_url,
    :instagram_url, :pinterest_url, :linkedin_url, :youtube_url, :corporate_contacts

  validates :url, :label, presence: true

  def initialize(params={})
    params = DEFAULT_PARAMS.merge(params)
    super
    # self.corporate_contacts_attributes = params.fetch(:corporate_contacts_attributes, [])
  end

  def corporate_contacts_attributes=(attrs)
    self.corporate_contacts = attrs.values.map do |cc|
      CorporateContact.new(cc)
    end
  end

end
