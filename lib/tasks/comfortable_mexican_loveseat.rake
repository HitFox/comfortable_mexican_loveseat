namespace :comfortable_mexican_loveseat do
  namespace :fixtures do
    
    desc 'Import Fixture data into database (options: FROM=folder_name TO=site_identifier)'
    
    task :import => :environment do
      from   = ENV['FROM']
      to     = ENV['TO'] || ENV['FROM']
      locale = ENV['LOCALE']
      
      if from
        puts "Importing CMS Fixtures from Folder [#{from}] to Site [#{to}] ..."
      else
        puts "Importing all CMS Fixtures ..."
      end
      
      # changing so that logger is going straight to screen
      logger = ComfortableMexicanSofa.logger
      ComfortableMexicanSofa.logger = Logger.new(STDOUT)
      
      if from
        ComfortableMexicanLoveseat::Fixture::Importer.new(from, to, :force).import!
      else
        Comfy::Cms::Site.pluck(:identifier).each do |from|
          to ||= from
          ComfortableMexicanLoveseat::Fixture::Importer.new(from, to, :force).import!
        end
        Dir["#{Rails.root}/db/cms_fixtures/*"].map { |dir| Pathname.new(dir).basename.to_s }.each do |from|
          to ||= from
          ComfortableMexicanLoveseat::Fixture::Importer.new(from, to, :force).import!
        end
      end
      
      ComfortableMexicanSofa.logger = logger
    end
  end
end

namespace :cms do
  task import: 'comfortable_mexican_loveseat:fixtures:import'
  task export: 'comfortable_mexican_loveseat:fixtures:export'
end