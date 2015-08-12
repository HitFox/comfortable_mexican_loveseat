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
          puts "Importing Fixtures from #{from} to #{to}"
          ComfortableMexicanLoveseat::Fixture::Importer.new(from, to, :force).import!
        end
        Dir["#{Rails.root}/db/cms_fixtures/*"].map { |dir| Pathname.new(dir).basename.to_s }.each do |from|
          next if from == 'sample_site'
          to ||= from
          
          puts "Importing Fixtures from #{from} to #{to}"
          ComfortableMexicanLoveseat::Fixture::Importer.new(from, to, :force).import!
        end
      end
      
      ComfortableMexicanSofa.logger = logger
    end
    
    desc 'Export database data into Fixtures (options: FROM=site_identifier TO=folder_name)'
    task :export => :environment do
      from  = ENV['FROM']
      to    = ENV['TO'] || ENV['FROM']
      
      if from
        puts "Exporting CMS data from Site [#{from}] to Folder [#{to}] ..."
      else
        puts "Exporting all CMS data ..."
      end
      
      # changing so that logger is going straight to screen
      logger = ComfortableMexicanSofa.logger
      ComfortableMexicanSofa.logger = Logger.new(STDOUT)
      
      if from
        ComfortableMexicanSofa::Fixture::Exporter.new(from, to).export!
      else
        Comfy::Cms::Site.pluck(:identifier).each do |from|
          to ||= from
          puts "Exporting Fixtures from #{from} to #{to}"
          ComfortableMexicanSofa::Fixture::Exporter.new(from, to).export!
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