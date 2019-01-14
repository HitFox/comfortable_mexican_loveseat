module ComfortableMexicanLoveseat::Fixture
  class Importer < ComfortableMexicanSofa::Seeds::Importer
    def initialize(from, to = from, force_import = false, locale = I18n.default_locale)
      self.site = Comfy::Cms::Site.find_or_create_by(:identifier => to, :locale => locale)
      super(from, to, force_import)
    end
  end
end
