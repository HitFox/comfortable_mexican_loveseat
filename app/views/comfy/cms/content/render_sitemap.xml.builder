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

  ComfortableMexicanLoveseat.seo_custom_paths.each do |options|
    xml.url do
      xml.loc [request.protocol, request.host_with_port, '/', options[:route]].join
      xml.lastmod options[:last_modified]
    end
  end

  ComfortableMexicanLoveseat.seo_resource_paths.each do |options|
    resource_class = options[:resource_class].kind_of?(String) ? options[:resource_class].constantize : options[:resource_class]
    resource_class_name = options[:resource_class].kind_of?(String) ? options[:resource_class] : options[:resource_class].name
    resource_class.where(options[:filter]).each do |obj|
      xml.url do
        xml.loc polymorphic_url(obj)
        xml.lastmod obj.updated_at.strftime('%Y-%m-%d')
      end
    end
  end

end
