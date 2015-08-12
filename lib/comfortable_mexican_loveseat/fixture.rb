module ComfortableMexicanLoveseat::Fixture
  class Importer < ComfortableMexicanSofa::Fixture::Importer
    def initialize(from, to = from, force_import = false, locale = I18n.default_locale)
      super(from, to, force_import)
      self.site = Comfy::Cms::Site.find_or_create_by(:identifier => to, :locale => locale)
    end
  end
end
