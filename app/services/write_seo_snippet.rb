class WriteSeoSnippet
  # snippet create is clicked
  #   method gets all input of the three categories.
  # First check which categorie(s) are choosen
  #   then write each content in the right space of the script file

  # Notes:
  #   No redundant commas!
  #   Contact case must have url or telephone to be valid!

  class << self
    def write_snippet(params)
      params = handle_params(params)
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
      logo, contact, profile = fill_content(params)
      seo_script = ''
      seo_script << '<script type="application/ld+json">'
      seo_script << '{'
      logo.each do |k,v|
        unless v.blank?
          if k == 'context' || k == 'type'
            seo_script << '"@'+k+'" : "'+v+'"'
          else
            seo_script << '"'+k+'" : "'+v+'"'
          end
          seo_script << ','
        end
      end
  #   "contactPoint" : [{
  #     "@type" : "ContactPoint",
  #     "telephone" : "+1-401-555-1212",
  #     "contactType" : "customer service"
  #   }]
      seo_script.chop!
      seo_script << ',"contactPoint" : [{'
      contact.each do |k,v|
        unless v.blank?
          if v.class == Array
            new_v = check_array_for_empty_brackets(v)
            (seo_script << '"'+k+'" : ['+new_v+']') unless new_v.blank?
          else
            seo_script << '"'+k+'" : "'+v+'"'
          end
          seo_script << ','
        end
      end
      seo_script << '}]'
  #   "sameAs" : [
  #     "http://www.facebook.com/your-profile",
  #     "http://www.twitter.com/yourProfile",
  #     "http://plus.google.com/your_profile"
  #   ]
      seo_script << ',"sameAs" : ['
      profile.each do |url|
        unless url.blank?
          seo_script << '"'+url+'"'
          seo_script << ','
        end
      end
      seo_script << ']'
      seo_script << '}'
      seo_script << '<script>'
      new_seo_script = delete_script_errors(seo_script)
      puts new_seo_script
      new_seo_script
      #return '<script type="application/ld+json">{"@context": "http://schema.org","@type": "Organization","url" : "http://www.your-site.com","name" : "Your Organization Name"}<script>'
    end

    def fill_content(params)
      logo = {}
      logo['context'] = params[:seo_snippet][:context]
      logo['type'] = params[:seo_snippet][:type]
      logo['url'] = params[:seo_snippet][:url]
      logo['logo'] = params[:seo_snippet][:logo]
      contact = {}
      contact['telephone'] = params[:seo_snippet][:telephone]
      contact['url'] = params[:seo_snippet][:contact_url]
      contact['contactType'] = params[:seo_snippet][:contact_type]
      contact['areaServed'] = params[:seo_snippet][:area_served]
      contact['availableLanguage'] = params[:seo_snippet][:available_language]
      profile = []
      profile << params[:seo_snippet][:facebook_url]
      profile << params[:seo_snippet][:twitter_url]
      profile << params[:seo_snippet][:google_plus_url]
      profile << params[:seo_snippet][:instagram_url]
      profile << params[:seo_snippet][:pinterest_url]
      profile << params[:seo_snippet][:linkedin_url]
      profile << params[:seo_snippet][:youtube_url]
      return logo, contact, profile
    end

    def delete_script_errors(seo_script)
      seo_script.sub!(/"sameAs" : \[\]/, '')
      seo_script.sub!(/"contactPoint" : \[{}\]/, '')
      seo_script.sub!(/,}\]/, '}]')
      seo_script.sub!(/,\]/, ']')
      seo_script.sub!(/,}/, '}')
      seo_script
    end

    def check_array_for_empty_brackets(v)
      v.join('","')
      num = v.index("")
      v.slice!(num) unless num.nil?
      v.to_s
    end

  # logo:
  # <script type="application/ld+json">
  #     {
  #       "@context": "http://schema.org",
  #       "@type": "Organization",
  #       "url": "http://www.example.com",
  #       "logo": "http://www.example.com/images/logo.png"
  #     }
  # </script>


  # contact:
  # <script type="application/ld+json">
  # {
  #   "@context" : "http://schema.org",
  #   "@type" : "Organization",
  #   "url" : "http://www.your-company-site.com",
  #   "contactPoint" : [{
  #     "@type" : "ContactPoint",
  #     "telephone" : "+1-401-555-1212",
  #     "contactType" : "customer service"
  #   }]
  # }
  # </script>


  # profile:
  # <script type="application/ld+json">
  # {
  #   "@context" : "http://schema.org",
  #   "@type" : "Organization",
  #   "name" : "Your Organization Name",
  #   "url" : "http://www.your-site.com",
  #   "sameAs" : [
  #     "http://www.facebook.com/your-profile",
  #     "http://www.twitter.com/yourProfile",
  #     "http://plus.google.com/your_profile"
  #   ]
  # }
  # </script>
  end
end
