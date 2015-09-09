class WriteSeoSnippet
  # snippet create is clicked
  #   method gets all input of the three categories.
  # First check which categorie(s) are choosen
  #   then write each content in the right space of the script file
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
      content = fill_content(params)
      seo_script =''
      seo_script << '<script type="application/ld+json">'
      seo_script << '{'
      content.each do |k,v|
        unless v.blank?
          if k == 'context' || k == 'type'
            seo_script << '"@'+k+'" : "'+v+'"'
          else
            seo_script << '"'+k+'" : "'+v+'"'
          end
          seo_script << ','
        end
      end
      seo_script << '}'
      seo_script.sub!(/,}/, '}')
      seo_script << '<script>'
      puts seo_script
      seo_script
      #return '<script type="application/ld+json">{"@context": "http://schema.org","@type": "Organization","url" : "http://www.your-site.com","name" : "Your Organization Name"}<script>'
    end

    def fill_content(params)
      content = {}
      content['context'] = params[:context]
      content['type'] = params[:type]
      content['url'] = params[:url]
      content['logo'] = params[:logo]
      content['same_url'] = params[:same_url]
      content['telephone'] = params[:telephone]
      content['area'] = params[:area]
      content['language'] = params[:language]
      content['facebook_url'] = params[:facebook_url]
      content['twitter_url'] = params[:twitter_url]
      content['google_plus_url'] = params[:google_plus_url]
      content['instagram_url'] = params[:instagram_url]
      content['pinterest_url'] = params[:pinterest_url]
      content['linkedin_url'] = params[:linkedin_url]
      content['youtube_url'] = params[:youtube_url]
      content
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
