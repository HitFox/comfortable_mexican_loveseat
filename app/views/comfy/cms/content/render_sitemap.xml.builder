xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'

xml.urlset :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @cms_site.pages.published.each do |page|
    xml.url do
      xml.loc [request.protocol.gsub('//', ''), page.url].join
      # just take some guesses the closer to the root means higher priority
      # start subtracting 0.1 for every additional child page, max out at 0.1
      # "/" splits to 0, "/child_page" splits to 2, hence weird max -1
      xml.priority [1 - (0.1 * ( ( [page.full_path.split("/").count, 1].max - 1 ) ) ), 0.1].max
      xml.lastmod page.updated_at.strftime('%Y-%m-%d')
    end
  end

  if ComfortableMexicanLoveseat.data.seo.custom_routes.present?
    ComfortableMexicanLoveseat.data.seo.custom_routes.each do |hash|
      xml.url do
        xml.loc [request.protocol, request.host_with_port, '/', hash[:route]].join
        xml.lastmod hash[:last_modified]
      end
    end
  end

  if ComfortableMexicanLoveseat.data.seo.model_routes.present?
    ComfortableMexicanLoveseat.data.seo.model_routes.each do |hash|
      hash[:model].constantize.send('where', hash[:where_args]).each do |obj|
        xml.url do
          xml.loc Rails.application.routes.url_helpers.send("#{hash[:model].underscore}_url", obj, host: [request.protocol, request.host_with_port].join)
          xml.lastmod obj.updated_at.strftime('%Y-%m-%d')
        end
      end
    end
  end

end
