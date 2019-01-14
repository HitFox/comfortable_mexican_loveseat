# require 'zip'
require 'fileutils'
require_relative 'zip_file_generator'

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
        ComfortableMexicanLoveseat::Seeds::Importer.new(from, to).import!
      else
        Dir["#{Rails.root}/db/cms_fixtures/*"].map { |dir| Pathname.new(dir).basename.to_s }.each do |from|
          next if from == 'sample-site'
          to ||= from
          
          puts "Importing Fixtures from #{from} to #{to}"
          ComfortableMexicanLoveseat::Seeds::Importer.new(from, to).import!
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
        ComfortableMexicanSofa::Seeds::Exporter.new(from, to).export!
      else
        Comfy::Cms::Site.pluck(:identifier).each do |from|
          to ||= from
          puts "Exporting Fixtures from #{from} to #{to}"
          ComfortableMexicanSofa::Seeds::Exporter.new(from, to).export!
        end
      end
      
      ComfortableMexicanSofa.logger = logger
    end

    desc 'Zip fixtures and save in a public dir'
    task zip: :environment do
      directoryToZip = ComfortableMexicanSofa.config.fixtures_path
      fileName = "cms_fixtures_#{Time.now.to_i}.zip"
      outputPath = File.expand_path('public/downloads', Rails.root)

      begin
        FileUtils.mkdir_p(outputPath)
      rescue
        puts 'rescued in mkdir'
      else
        begin
          FileUtils.chmod_R(0755, outputPath)
        rescue
          puts 'rescued in chmod'
        else
          outputFile = [outputPath, fileName].join('/')
          zf = ZipFileGenerator.new(directoryToZip, outputFile)
          zf.write()
          FileUtils.chmod_R(0777, outputFile)
          puts "Zipped to #{fileName}"
          puts outputPath
        end
      end
    end
  end
end

namespace :cms do
  task import: 'comfortable_mexican_loveseat:fixtures:import'
  task export: 'comfortable_mexican_loveseat:fixtures:export'
  task zip:    'comfortable_mexican_loveseat:fixtures:zip'
end
