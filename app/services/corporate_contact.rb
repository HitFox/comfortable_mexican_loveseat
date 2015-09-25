class CorporateContact
  include ActiveModel::Model

  # each corporate contact is a single instance and gets validated alone.
  # => They belong to seo_snippet model

  attr_accessor :telephone, :contact_url, :contact_type, :area_served,
                :available_language, :contact_type_selected

  validates :telephone,
      format: { with: /\A\+[\d*| *|\-]+\z/,
      message: "only allows numbers with international country code prefix"},
      presence: true, unless: Proc.new{|u| u.contact_type.blank? }
  validates :telephone,
      absence: true, if: Proc.new{|u| u.contact_type.blank? }
end
