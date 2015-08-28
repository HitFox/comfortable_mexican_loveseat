module Routify
  extend ActiveSupport::Concern

 included do
   helper_method :current_namespace, :current_parent, :site_url, :site
   
   def namespaces
     self.class.namespaces
   end
 end

 private
 
 def current_parent
   parent if respond_to?(:parent, true)
 end
 
 def current_namespace
   namespaces.first
 end
  
  def site_url
    'site' if params[:site_id].present?
  end

  def site (current_resource = resource)
    current_resource.site if current_resource.respond_to?(:site)
  end

 module ClassMethods
   def current_namespace
     namespaces.first
   end

   def namespaces
     name.split('::').slice(0...-1).map(&:underscore).map(&:to_s)
   end
 end
end
