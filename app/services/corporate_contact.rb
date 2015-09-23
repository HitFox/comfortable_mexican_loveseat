class CorporateContact
  include ActiveModel::Model
  # include ActiveModel::Validations
  # extend ActiveModel::Naming


  # each corporate contact is a single instance and gets validated alone.
  # => They belong to seo_snippet model

  attr_accessor :telephone, :contact_url,
  :contact_type, :area_served, :available_language, :contact_type_selected, :number_of_contacts

  # validates :contact_type, absence: true
  # validates :telephone,
  #     format: { with: /\A\+?[\d*| *|\-]+\z/,
  #     message: "only allows numbers"},
  #     presence: true, if: Proc.new{|u| u.contact_type_selected }
  # validates :telephone,
  #     absence: true, unless: Proc.new{|u| u.contact_type_selected }
  # validate :attributes_valid?

  def attributes_valid?
    number = @number_of_contacts
    num = 1
    while (number.to_i+1) > num do
      # get index of symbol in instance_variables(std_array)
      # fetch object in index to check if blank and compare to second object if also blank
      index_telephone = instance_variables.index("@telephone_#{num}".to_sym)
      index_contact_type = instance_variables.index("@contact_type_#{num}".to_sym)

      #check if both indexes are there, if not check if both are missing otherwise throw error
      tel = false
      cont = false
      if index_telephone
        telephone = instance_variables[index_telephone]
        if telephone.match(/\A\+?[\d*| *|\-]+\z/)
          tel = true
        end
      end
      if index_contact_type
        contact_type = instance_variables[index_contact_type]
        cont = true
      end
      if tel && cont
        #thats fine, right?
      elsif tel || cont
        # that's bad
        #throw error
        # errors.add telephone.to_sym, 'missing' #if ("telephone_#{num}").to_sym.blank? && !("contact_type_#{num}").to_sym.blank?
      else #both missing
        # that's fine too
      end
      num += 1
    end
  end

      # SeoSnippet.instance_methods.each do |instance|
      #   # if instance.match(/telephone/)
      #   #   puts 'instance:'
      #   #   puts instance
      #   # elsif instance.match(/contact_type/)
      #     puts 'instance:'
      #     puts instance
      #   # end
      # end
      # instance_variables.each do |instance|
      #   puts 'inst>'
      #   puts instance
      #   puts instance.class
      # end

end
