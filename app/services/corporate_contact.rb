class CorporateContact
  include ActiveModel::Model

  # each corporate contact is a single instance and gets validated alone.
  # => They belong to seo_snippet model

  attr_accessor :telephone, :contact_url, :contact_type, :area_served,
                :available_language

  validates :telephone,
      format: { with: /(\A\+[1-9][\d*| *|\-]+\z|\A\z)/,
      message: 'only allows numbers with international country code prefix, like +49'},
      absence: { if: Proc.new{|u| u.contact_type.blank? },
        message: 'needs input of contact type' }
  validates :contact_url,
      absence: { if: Proc.new{|u| u.contact_type.blank? },
        message: 'needs input of contact type' }
  validates :area_served,
      absence: { if: Proc.new{|u| !u.area_served.join.blank? && u.contact_type.blank? },
        message: 'needs input of contact type' }
  validates :available_language,
      absence: { if: Proc.new{|u| !u.available_language.join.blank? && u.contact_type.blank? },
        message: 'needs input of contact type' }
  validates :contact_type,
      absence: { if: Proc.new{|u| u.telephone.blank? && u.contact_url.blank? },
        message: 'needs input of contact url or telephone' }
end
