class CorporateContact
  include ActiveModel::Model

  # each corporate contact is a single instance and gets validated alone.
  # => They belong to seo_snippet model

  attr_accessor :telephone, :contact_url, :contact_type, :area_served,
                :available_language, :contact_type_selected

  validates :telephone,
      format: { with: /(\A\+[\d*| *|\-]+\z|\A\z)/,
      message: "only allows numbers with international country code prefix"},
      absence: { if: Proc.new{|u| u.contact_type.blank? },
        message: 'needs input of contact url' }
  validates :contact_url,
      absence: { if: Proc.new{|u| u.contact_type.blank? },
        message: 'needs input of contact url' }
  validates :contact_type,
      absence: {if: Proc.new{|u| u.telephone.blank? && u.contact_url.blank? },
        message: "needs input of contact url or telephone"}
end
