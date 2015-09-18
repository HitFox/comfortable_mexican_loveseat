class SeoSnippet
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :label, :context, :type, :url, :logo, :telephone_0, :contact_url_0,
    :contact_type_0, :area_served_0, :available_language_0, :facebook_url, :twitter_url, :google_plus_url, :instagram_url,
    :pinterest_url, :linkedin_url, :youtube_url, :contact_type_selected, :telephone, :contact_url,
    :contact_type, :area_served, :available_language, :hidden_number_from_view

  validates :url, :label, presence: true
  validates :contact_type_0, absence: true
  validates :telephone_0,
      format: { with: /\A\+?[\d*| *|\-]+\z/,
      message: "only allows numbers"},
      presence: true, if: Proc.new{|u| u.contact_type_selected }
  validates :telephone_0,
      absence: true, unless: Proc.new{|u| u.contact_type_selected }

  def create_missing_attributes(number_as_string)
    num = 1
    puts number_as_string
    while (number_as_string.to_i+1) > num do
      self.class.__send__(:attr_accessor, "telephone_#{num}")
      self.class.__send__(:attr_accessor, "contact_url_#{num}")
      self.class.__send__(:attr_accessor, "contact_type_#{num}")
      self.class.__send__(:attr_accessor, "area_served_#{num}")
      self.class.__send__(:attr_accessor, "available_language_#{num}")
      num += 1
    end
  end
end
