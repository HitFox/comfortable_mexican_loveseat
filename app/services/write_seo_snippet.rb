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
      params[:snippet][:label] = "seo_#{time}"
      params[:snippet][:identifier] = "seo_#{time}"
      params[:snippet][:content] = seo_scripter(params).to_s
      params
    end

    def seo_scripter(params)
      logo, contact, profile = fill_content(params)
      seo_script =''
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
          seo_script << '"'+k+'" : "'+v+'"'
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
      logo['context'] = params[:context]
      logo['type'] = params[:type]
      logo['url'] = params[:url]
      logo['logo'] = params[:logo]
      contact = {}
      contact['url'] = params[:same_url]
      contact['telephone'] = params[:telephone]
      contact['contactType'] = params[:contact_type]
      profile = []
      profile << params[:facebook_url]
      profile << params[:twitter_url]
      profile << params[:google_plus_url]
      profile << params[:instagram_url]
      profile << params[:pinterest_url]
      profile << params[:linkedin_url]
      profile << params[:youtube_url]
      return logo, contact, profile
    end

    def delete_script_errors(seo_script)
      seo_script.sub!(/"sameAs" : \[\]/, '')
      seo_script.sub!(/"contactPoint" : \[{}\]/, '')
      seo_script.sub!(/,}]/, '}]')
      seo_script.sub!(/,]/, ']')
      seo_script.sub!(/,}/, '}')
      seo_script
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
