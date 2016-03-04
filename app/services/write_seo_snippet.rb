class WriteSeoSnippet
  # Writes a json script for structured data (https://developers.google.com/structured-data/)
  # => The script can have three parts: logo, corporate contacts and social profiles
  # => The finished script unites all this parts in one script, where @type, @context and url are mandatory
  # => In the end (with all parts included) it looks like this:

  # <script type="application/ld+json">
  #   {
  #     "@context": "http://schema.org",
  #     "@type": "Organization",
  #     "url": "http://www.example.com",
  #     "logo": "http://www.example.com/images/logo.png",
  #     "contactPoint" : [{
  #       "@type" : "ContactPoint",
  #       "telephone" : "+1-401-555-1212",
  #       "contactType" : "customer service"
  #     }],
  #     "sameAs" : [
  #       "http://www.facebook.com/your-profile",
  #       "http://www.twitter.com/yourProfile",
  #       "http://plus.google.com/your_profile"
  #     ]
  #   }
  # </script>

  # Important:
  # => Redundant commas crashes json script
  # => Corporate contacts must have url or telephone to be valid

  class << self
    def write_snippet(params)
      handle_params(params)
    end

    def handle_params(params)
      time = Time.new.strftime("%m-%d-%Y_%H%M%S")
      params[:snippet] = {}
      params[:snippet][:label] = "#{params[:seo_snippet][:label]}_#{time}"
      params[:snippet][:identifier] = "#{params[:seo_snippet][:label]}_#{time}"
      params[:snippet][:content] = seo_scripter(params).to_s
      params
    end

    def seo_scripter(params)
      mandatory_and_logo, contacts, profile = fill_content(params)

      seo_script = ''
      seo_script << '<script type="application/ld+json">'
      seo_script << '{'
      mandatory_and_logo.each do |k,v|
        unless v.blank?
          if k == 'context' || k == 'type'
            seo_script << '"@'+k+'" : "'+v+'"'
          else
            seo_script << '"'+k+'" : "'+v+'"'
          end
          seo_script << ','
        end
      end
      seo_script << '"contactPoint" : [{'
      contacts.each do |contact_number, contact_content|
        puts 'contact:'
        puts contact_content
        seo_script << '"@type" : "ContactPoint"'
        contact_content.each do |k,v|
          #v counter to check if all v blank, to delete seo_script << '"@type" : "ContactPoint",'
          if v.class == Array
            unless v.join.blank?
              seo_script << ','
              new_v = delete_select_attributes_empty_quotes(v)
              (seo_script << '"'+k+'" : ['+new_v+']') unless new_v.blank?
            end
          else
            unless v.blank?
              seo_script << ','
              v.gsub!(/_/, ' ')
              seo_script << '"'+k+'" : "'+v+'"'
            end
          end
        end
        seo_script << '},{'
      end
      seo_script << '}]'
      seo_script.gsub!(/,\{\}/, '')
      seo_script << ',"sameAs" : ['
      profile.each do |url|
        unless url.blank?
          seo_script << '"'+url+'"'
          seo_script << ','
        end
      end
      seo_script.chop!
      seo_script << ']'
      seo_script << '}'
      seo_script << '</script>'
      new_seo_script = delete_script_errors(seo_script)
      new_seo_script
    end

    def fill_content(params)
      mandatory_and_logo = {}
      mandatory_and_logo['context'] = params[:seo_snippet][:context]
      mandatory_and_logo['type'] = params[:seo_snippet][:type]
      mandatory_and_logo['url'] = params[:seo_snippet][:url]
      mandatory_and_logo['logo'] = params[:seo_snippet][:logo]
      contacts = {}
      params[:seo_snippet][:corporate_contacts_attributes].each do |contact_id, contact_values|
        contacts[contact_id] = {}
        contacts[contact_id]['contactType'] = contact_values[:contact_type]
        contacts[contact_id]['telephone'] = contact_values[:telephone]
        contacts[contact_id]['url'] = contact_values[:contact_url]
        contacts[contact_id]['areaServed'] = contact_values[:area_served]
        contacts[contact_id]['availableLanguage'] = contact_values[:available_language]
      end
      profile = []
      profile << params[:seo_snippet][:facebook_url]
      profile << params[:seo_snippet][:twitter_url]
      profile << params[:seo_snippet][:google_plus_url]
      profile << params[:seo_snippet][:instagram_url]
      profile << params[:seo_snippet][:pinterest_url]
      profile << params[:seo_snippet][:linkedin_url]
      profile << params[:seo_snippet][:youtube_url]
      return mandatory_and_logo, contacts, profile
    end

    def delete_select_attributes_empty_quotes(v)
      v.join('","')
      num = v.index("")
      v.slice!(num) unless num.nil?
      v.to_s
    end

    def delete_script_errors(seo_script)
      seo_script.sub!(/,"sameAs" : \]/, '')
      seo_script.sub!(/,"contactPoint" : \[\{"@type" : "ContactPoint"\}\]/, '')
      seo_script.sub!(/,\{"@type" : "ContactPoint"\}/, '')
      seo_script
    end
  end
end
