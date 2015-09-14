class SeoSnippet
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :context, :type, :url, :logo, :same_url, :telephone, 
    :contact_type, :area_served, :available_language, :facebook_url, :twitter_url, :google_plus_url, :instagram_url,
    :pinterest_url, :linkedin_url, :youtube_url

  # def initialize(attributes = {})
  #   @attributes = attributes
  # end

  # def validate
  #   record = {}

  #   if @attributes[:url].blank?
  #     return false
  #   else
  #     return true
  #   end





    # @attributes.each do |attri, value|
    #   if value.to_s[0].blank?
    #     puts '////////////////dfsdfsd'
    #   else
    #     puts '/////////dfdfsfsdf///////'
    #   end
    #   record[attri] = "#{attri.to_s} can't be blank" if value.to_s.blank?
    # end
    # if record.blank?
    #   return true
    # else
    #   return false
    # end
  # end
end
