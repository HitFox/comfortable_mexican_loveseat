class Crawler
  # crawles the given webpage and it's children and fetches their attributes.
  def initialize(webpage)
    @key_url = webpage
    @notes_hash = {}
    @url_hash = {}
    @attributes_hash = {}
    @valid_urls_array =[]
    @untested_urls_array =[]
    @system_urls_array =[]
    @error_urls_hash = {}
    @http_response_urls_array = []
    @doc = ''
  end

  def crawl_webpage
    edit_key_url(@key_url.dup)
    search_url_hash(@key_url)
    seo_checker = SeoCheck.new(@attributes_hash, @key_url)
    seo_checker.check_seo
    url_HTTP_response(@url_hash)
    color_calculator(@attributes_hash)
    return_all
  end

  def edit_key_url(key_url)
    # creates domain. and www.domain.
    key_url.match(/(https?:\/\/)(www\.|)(\b\S+)[\.]/)
    @www_key_url = $1+'www.'+$3+'.'
    @non_www_key_url = $1+$3+'.'
  end

  def search_url_hash(key_url)
    count = 0
    url_array = []
    @url_hash[key_url] = ['valid', key_url]
    url_array << key_url
    url_array.each do |url|
      count +=1
      if @url_hash[url].first == 'valid'
        if count > 300
          @notes_hash['too many links on all webpage?'] = 'yes, more than 300, please check!'
        end
        if get_url_list_of(url)
        # double check for valid, so no error if in rescue case
          fetcher_of(url)
          @url_hash.keys.each do |key|
            url_array << key
          end
          url_array.uniq!
        end
      end
    end
    divide_url_hash
  end

  def get_url_list_of(page_url)
    if Rails.env.development?
      puts page_url
    end
    begin
      @doc = Nokogiri::HTML(open(page_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, allow_redirections: :all),nil,'UTF-8')
      @doc.xpath('//comment()').remove
      @doc.xpath('//@href').each do |url|
        attribute_to_url(url.to_s, page_url)
      end
    rescue OpenURI::HTTPError => e
      if e.message
        @url_hash[page_url][0] = e.message
        return false
      end
    end
    return true
  end

  def attribute_to_url(url, parent_url)
    if !url.ascii_only?
      @url_hash[url] = ['untested', parent_url]
    else
      case url
      when /mailto:/
        @url_hash[url] = ['system', parent_url]
      when /\s/
        @url_hash[url] = ['untested', parent_url]
      when /\.pdf$/
        @url_hash[url] = ['system', parent_url]
      when /\.svg$/
        @url_hash[url] = ['system', parent_url]
      when /\.ico$/
        @url_hash[url] = ['system', parent_url]
      when /\.png$/
        @url_hash[url] = ['system', parent_url]
      when /\.css$/
        @url_hash[url] = ['system', parent_url]
      when /\.jpg$/
        @url_hash[url] = ['system', parent_url]
      when /^www./
        @url_hash[url] = ['untested', parent_url]
      when /^\/\/www./
        @url_hash[url] = ['untested', parent_url]
      when /^(?!http)/
        attribute_to_url(add_domain_to_url(url), parent_url)
      when /^#{@www_key_url}/
        @url_hash[url] = ['valid', parent_url]
      when /^#{@non_www_key_url}/
        @url_hash[url] = ['valid', parent_url]
      else
        @url_hash[url] = ['untested', parent_url]
      end
    end
  end

  def add_domain_to_url(url)
    unless url.match(/^\//)
      url = '/'+url
    end
    @key_url+url
  end

  def divide_url_hash
    @url_hash.each do |url, validator|
      if url != @key_url
        case validator.first
        when 'valid'
          @valid_urls_array << [url, validator.last] 
        when 'untested'
          @untested_urls_array << [url, validator.last]
        when 'system'
          @system_urls_array << [url, validator.last]
        else
          @error_urls_hash[url] = validator
        end
      end
    end
  end

  def fetcher_of(page_url)
    # Fetch and parse HTML document
    all_h1_header = []
    all_h2_header = []
    all_h3_header = []
    all_h4_header = []
    all_h5_header = []
    all_h6_header = []
    title = []
    meta_description = []
    all_links = []
    p_tag = []
    canon_links = []
    img_tags = []
    result_hash = {}
    @count_for_color_of_url = 0

    @doc.xpath('//h1').each do |header|
      all_h1_header << header.text
    end
    @doc.xpath('//h2').each do |header|
      all_h2_header << header.text
    end
    @doc.xpath('//h3').each do |header|
      all_h3_header << header.text
    end
    @doc.xpath('//h4').each do |header|
      all_h4_header << header.text
    end
    @doc.xpath('//h5').each do |header|
      all_h5_header << header.text
    end
    @doc.xpath('//h6').each do |header|
      all_h6_header << header.text
    end

    @doc.xpath('//title').each do |t|
      title << t.text
    end

    @doc.xpath('//meta[@name="description"]').each do |description|
      meta_description << description.to_s
    end

    @doc.xpath('//a[@href]').each do |link|
      all_links << link
    end

    @doc.xpath('//p').each do |p|
      p_tag << p.text
    end
    check_length(p_tag)

    @doc.xpath('//link[@rel="canonical"]').each do |can_links|
      canon_links << can_links
    end

    @doc.xpath('//img').each do |pic|
      img_tags << pic.to_s
    end

    result_hash[:all_h1_header] = all_h1_header
    result_hash[:all_h2_header] = all_h2_header
    result_hash[:all_h3_header] = all_h3_header
    result_hash[:all_h4_header] = all_h4_header
    result_hash[:all_h5_header] = all_h5_header
    result_hash[:all_h6_header] = all_h6_header
    result_hash[:title] = title
    result_hash[:meta_description] = find_description(meta_description)
    result_hash[:all_links_on_page] = find_links(all_links)
    result_hash[:p_tag_with_more_than_150_words?] = p_tag.last
    result_hash[:canonical_links] = canon_links
    result_hash[:image_and_alt] = check_alt_tag(img_tags)
    @attributes_hash[page_url] = [result_hash, @count_for_color_of_url]
  end

  def find_description(meta_description_nokogiri)
    desc = []
    meta_description_nokogiri.each do |content|
      content.to_s.match(/content=.([^=]+)("|')/)
      desc << ($1.nil? ? 'nothing found' : $1)
      @count_for_color_of_url += 1 if $1.nil?
    end
    desc
  end

  def find_links(all_links_nokogiri)
    just_links = []
    all_links_nokogiri.each do |content|
      content.to_s.match(/href=.([^"]+)/)
      just_links << ($1.nil? ? content.to_s+' *unable to match*' : $1)
    end
    just_links
  end

  def check_length(attri)
    temp = attri.dup
    text_to_long = false
    temp.each do |text|
      if text.encoding == 'UTF-8'
        if text.split(' ').size > 150
          attri << 'yes: ' + text
          text_to_long = true
          @count_for_color_of_url += 1
        end
      # do i need a warning here?
      end
    end
    attri << 'no' unless text_to_long
  end

  def check_alt_tag(images)
    image_tag_hash = {}
    images.each do |img|
      # put src and alt of imgage in a hash
      img.match(/src\w*=.?("\S+)/)
      src = ($1.nil? ? 'no_src_found' : $1)
      img.match(/alt=\W+((\w|\s)+)/)
      alt = ($1.nil? ? 'no_alt_found' : $1)
      @count_for_color_of_url += 1 if $1.nil?
      image_tag_hash[src] = alt
    end
    image_tag_hash
  end

  def url_HTTP_response(url_array)
    url_array.each do |url|
      if url.first.match(/^mailto:/)
        next
      end
      temp = url.first
      unless url.first.match(/^http/)
        unless url.first.match(/^www./) || url.first.match(/^\/\/www./)
          temp = add_domain_to_url(url.first)
        end
      end
      get_HTTP_response(temp, url, 0)
    end
    @http_response_urls_array
  end

  def get_HTTP_response(temp, url, round)
    begin
      if round == 0
        resp = Net::HTTP.get_response(URI.parse(temp))
      else
        uri = URI.parse(temp)
        http = Net::HTTP.new(uri.host, uri.port)
        temp.match(/https:\/\//) ? http.use_ssl = true : http.use_ssl = false
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        if round == 1
          request = Net::HTTP::Get.new(uri.request_uri)
        else
          request = Net::HTTP::Get.new(uri.request_uri, 'Accept-Encoding' => 'identity')
        end
        resp = http.request(request)
      end
      unless resp.code.match(/200/)
        @http_response_urls_array << [resp.code, ['"'+url.first+'"', url.last[1]]]
      end
    rescue Exception => e
      if round == 0
        get_HTTP_response(temp, url, 1)
      end
      if round == 1
        get_HTTP_response(temp, url, 2)
      end
      if round == 2
        @http_response_urls_array << ['*'+e.message+'*', ['"'+url.first+'"', url.last[1]]]
      end
    end
  end

  def color_calculator(attributes_hash)
    attributes_hash.each do |url, attributes|
      count = attributes.last
      if count == 0
        attributes[1] = 'zero'
      elsif count < 6
        attributes[1] = 'one'
      else
        attributes[1] = 'two'
      end
    end
  end

  def return_all
    result = {}
    result[:attributes_hash] = @attributes_hash
    result[:system_urls_array] = @system_urls_array
    result[:untested_urls_array] = @untested_urls_array
    result[:not_200_http_response_urls] = @http_response_urls_array
    result[:system_notes] = @notes_hash
    result
  end
end
