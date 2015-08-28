module Localizify
  extend ActiveSupport::Concern
  
  included do
    helper_method :default_locale?
    
    prepend_before_action :set_available_locale, :set_locale
  end
  
  def default_locale?
    I18n.locale == I18n.default_locale
  end
  
  def set_available_locale
    begin
      unless (cms_locales = ::Comfy::Cms::Site.pluck(:locale)).any?
        cms_locales = [I18n.default_locale]
      end
    rescue
      cms_locales = [I18n.default_locale]
    end

    I18n.available_locales = cms_locales.uniq
  end
  
  def set_locale
    return true if kind_of?(Comfy::Cms::ContentController)
    
    unless [params[:locale].try(:to_sym)].compact.include?(parsed_locale.to_sym)
      begin
        redirect_to url_for(locale: parsed_locale)
      rescue
        redirect_to root_path(locale: parsed_locale)
      end
    end
    
    I18n.locale = parsed_locale
    cookify_locale
  end
  
  def parsed_locale
    cms_locale || param_locale || cookie_locale || accept_locale || I18n.default_locale
  end
  
  def cookify_locale
    cookies[:locale] = { value: I18n.locale.to_s, expires: 1.year.from_now }
  end
  
  def uncookify_locale
    cookies.delete(:locale)
  end

  def locale_available?(locale)
    I18n.available_locales.include?(locale.try(:to_sym))
  end
  
  def cms_locale
    nil
  end
  
  def user_locale
    current_user && locale_available?(current_user.domain) ? current_user.domain.to_sym : nil
  end

  def param_locale
    locale_available?(params[:locale]) ? params[:locale].try(:to_sym) : nil
  end

  def cookie_locale
    cookies[:locale] && locale_available?(cookies[:locale]) ? cookies[:locale].try(:to_sym)  : nil
  end

  def domain_locale
    parsed_locale = request.host.split('.').last.try(:to_s)
    locale_available?(parsed_locale) ? parsed_locale.try(:to_sym)  : nil
  end
  
  def accept_locale
    if request.env['HTTP_ACCEPT_LANGUAGE'].present?
      parsed_locale = request.env['HTTP_ACCEPT_LANGUAGE'].gsub(/\s+/, '').split(',').first
      parsed_locale = parsed_locale.scan(/^[a-z]{2}-[a-z]{2}|[a-z]{2}/i).first if parsed_locale
      parsed_locale = parsed_locale.split('-').last.try(:downcase).try(:to_sym) if parsed_locale
      
      locale_available?(parsed_locale) ? parsed_locale.try(:to_sym)  : nil
    end
  end

  def default_url_options(options = {})
    options.merge(locale: I18n.locale || I18n.default_locale)
  end
  
end
