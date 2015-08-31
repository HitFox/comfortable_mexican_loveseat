require 'comfortable_mexican_sofa'
require 'rack-rewrite'
require 'open_uri_redirections'
require 'comfortable_mexican_loveseat/engine'
require 'comfortable_mexican_loveseat/fixture'
require 'comfortable_mexican_loveseat/cms_admin'
require 'comfortable_mexican_loveseat/form_builder'

module ComfortableMexicanLoveseat
  mattr_accessor :seo_custom_paths
  mattr_accessor :seo_resource_paths
  @@seo_custom_paths = []
  @@seo_resource_paths = []

  def self.setup
    yield self
  end
end
