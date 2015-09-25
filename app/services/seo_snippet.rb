class SeoSnippet
  include ActiveModel::Model
  extend ActiveModel::Naming

  DEFAULT_PARAMS = {
    "corporate_contacts_attributes" => {"0" => {}},
    "label" => "seo_snippet",
    "context" => "http://schema.org",
    "type" => "Organization"
  }

  attr_accessor :label, :context, :type, :url, :logo, :facebook_url, :twitter_url, :google_plus_url,
    :instagram_url, :pinterest_url, :linkedin_url, :youtube_url, :corporate_contacts,
    :corporate_contacts_attributes

  validates :url, presence: true
  validates :label, presence: true,
           format: { with: /\A[^\s]+\z/, message: "allows no blanks!"}

  def initialize(params={})
    params = DEFAULT_PARAMS.merge(params)
    super # calls (amongst other methods): corporate_contacts_attributes=(attrs)
  end

  def corporate_contacts_attributes=(attrs)
    self.corporate_contacts = attrs.values.map do |cc|
      CorporateContact.new(cc)
    end
  end

  def corporate_contacts_validator
    error_hash = {}
    @corporate_contacts.each do |contact|
      unless contact.valid?
        contact.errors.messages.each do |error_name, error_message|
          error_hash[error_name] = error_message.join
        end
      end
    end
    return error_hash
  end
end
