require 'comfortable_mexican_sofa'
require 'comfortable_mexican_loveseat/engine'

module ComfortableMexicanLoveseat
  mattr_accessor :data
  @@data = nil

  def self.setup
    yield self
  end
end
