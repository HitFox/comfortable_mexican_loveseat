class CorporateContact
  include ActiveModel::Model


  attr_accessor :telephone, :contact_url, :contact_type, :area_served,
                :available_language

  validates :telephone,
      format: { with: /(\A\+[1-9][\d*| *|\-]+\z|\A\z)/,
      message: 'international_number'},
      absence: { if: Proc.new{|u| u.contact_type.blank? },
        message: 'contact_type_blank' }
  validates :contact_url,
      absence: { if: Proc.new{|u| u.contact_type.blank? },
        message: 'contact_type_blank' }
  validates :area_served,
      absence: { if: Proc.new{|u| !u.area_served.join.blank? && u.contact_type.blank? },
        message: 'contact_type_blank' }
  validates :available_language,
      absence: { if: Proc.new{|u| !u.available_language.join.blank? && u.contact_type.blank? },
        message: 'contact_type_blank' }
  validates :contact_type,
      absence: { if: Proc.new{|u| u.telephone.blank? && u.contact_url.blank? },
        message: 'blank' }
end
