class SeoChecker
  class << self
    def check_seo(key_url)
      url_hash = PreprocessUrls.new(key_url).run
      attributes_hash = CrawlPage.new(url_hash).run
      enlarged_attributes_hash = JudgeContent.new(key_url, attributes_hash).judge
      sorted_url_hash = sort_url_hash(url_hash, key_url)
      sorted_enlarged_attributes_hash = sort_attributes_hash(enlarged_attributes_hash)

      result_hash = {
        sorted_attributes_hash: sorted_enlarged_attributes_hash,
        sorted_urls_hash: sorted_url_hash
      }
      return result_hash
    end

    def sort_url_hash(url_hash, key_url)
      sorted_url_hash = {}
      valid_urls = []
      intern_urls = []
      extern_urls = []
      system_urls = []
      error_urls = []
      code_200_urls = []
      redirected_urls = []
      code_error_urls = []

      # this is going to be the hashes structure:
      #   @url_hash[child_url] = [label, parent_url, code, doc, child_url.dup, redirect_target]
      url_hash.each do |url, values|
        case values[0]
        when 'valid'
          valid_urls << [url, values[1]] 
        when 'untested'
          if get_domain(url) == get_domain(key_url)
            intern_urls << [url, values[1]]
          else
            extern_urls << [url, values[1]]
          end
        when 'system'
          system_urls << [url, values[1]]
        else
          error_urls << [url, values[0]]
        end
        case values[2]
        when /200/
          code_200_urls << [url, values[1], values[2]] 
        when /30\d/
          redirected_urls << [url, values[1], values[2], values[5]] 
        else
          code_error_urls << [url, values[1], values[2]] unless values[0] == 'system'
        end
      end
      sorted_url_hash['Valid'] = valid_urls
      sorted_url_hash['Intern'] = intern_urls
      sorted_url_hash['Extern'] = extern_urls
      sorted_url_hash['System'] = system_urls
      sorted_url_hash['Error'] = error_urls
      sorted_url_hash['Code_200'] = code_200_urls
      sorted_url_hash['Redirected'] = redirected_urls
      sorted_url_hash['Code_error'] = code_error_urls

      sorted_url_hash
    end

    def get_domain(url)
      url.match(/https?:\/\/(www\.|)(\b\S+)[\.]/)
      $2.to_s
    end

    def sort_attributes_hash(attributes_hash)
      sorted_enlarged_attributes_hash = {}

      attributes_hash.each do |url, attributes|
        head = []
        headings = []
        content = []
        image = []
        new_attributes = {}

        attributes.first.each do |name, value|
          case name.to_s
          when /head_/
            name.to_s.match(/head_(.+)/)
            head << [$1, value]
          when /headings_/
            name.to_s.match(/headings_(.+)/)
            headings << [$1, value]
          when /content_/
            name.to_s.match(/content_(.+)/)
            content << [$1, value]
          when /image_/
            name.to_s.match(/image_(.+)/)
            image << [$1, value]
          else
            puts 'missed something in divide_attributes_hash'
          end
        end
        new_attributes['Head'] = head
        new_attributes['Headings'] = headings
        new_attributes['Content'] = content
        new_attributes['Image'] = image

        sorted_enlarged_attributes_hash[url] = [new_attributes, attributes.last]
      end
      
      sorted_enlarged_attributes_hash
    end
  end
end
