class PreprocessUrls
  def initialize(key_url)
    @key_url = key_url
    # @url_hash[child_url] = [label, parent_url, code, doc, child_url.dup]
    @url_hash = {}
    @notes_hash = {}
  end

  def run
    dup_key_url(@key_url)
    fill_url_hash(@key_url)
    @url_hash
  end

  def dup_key_url(key_url)
    # creates domain. and www.domain.
    key_url.match(/(https?:\/\/)(www\.|)(\b\S+)[\.]/)
    @www_key_url = $1+'www.'+$3+'.'
    @non_www_key_url = $1+$3+'.'
  end
  
  def fill_url_hash(key_url)
    @url_hash[key_url] = ['valid', key_url]
    url_array = []
    url_array << key_url
    url_array.each do |url|
      if get_all_urls_of(url)
        @url_hash.keys.each do |key|
          url_array << key
        end
        url_array.uniq!
      end
    end
  end

  def get_all_urls_of(parent_url)
    code = 0
    doc = ''
    @url_hash[parent_url][4] = check_domain(parent_url)
    # puts 'copy '+@url_hash[parent_url][4]
    begin
      body, code = get_HTTP_and_code(@url_hash[parent_url][4].dup, 0, nil)
      doc = Nokogiri::HTML(body)
      @url_hash[parent_url][2] = code
      @url_hash[parent_url][3] = doc
      # puts '0 '+@url_hash[parent_url][0]
      # puts '1 '+@url_hash[parent_url][1]

      if url_label(parent_url) == 'valid'
        doc.xpath('//comment()').remove
        doc.xpath('//@href').each do |child_url|
          label_url(child_url.to_s, parent_url)
        end
      end
      # puts '2 '+@url_hash[parent_url][2]
      # puts '4 '+@url_hash[parent_url][4]
      # puts'.......fine............'

    rescue Exception => e
      if e.message
        # puts 'me e mesaeg: ' +e.message
        @url_hash[parent_url][0] = e.message
        @url_hash[parent_url][2] = e.message
        @url_hash[parent_url][3] = 'empty'
        # puts @url_hash[parent_url][0]
        # puts @url_hash[parent_url][1]
        # puts @url_hash[parent_url][2]
        # puts @url_hash[parent_url][4]
        # puts'......error.............'
        return false
      end
    end
    return true
  end

  def check_domain(url)
    new_url = url
    unless url.match(/^http/)
      # if url.match(/^www./) || url.match(/^\/\/www./)

      # end
      new_url = add_domain_to(url)
    end
    new_url
  end

  def add_domain_to(url)
    unless url.match(/^\//)
      url = '/'+url
    end
    @key_url+url
  end

  def get_HTTP_and_code(url, round, code)
    begin
      if round == 0
        resp = Net::HTTP.get_response(URI.parse(url))
      else
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        if round == 1
          request = Net::HTTP::Get.new(uri.request_uri)
        else
          request = Net::HTTP::Get.new(uri.request_uri, 'Accept-Encoding' => 'identity')
        end
        resp = http.request(request)
      end
    rescue Exception => e
      if round == 0
        get_HTTP_and_code(url, 1, nil)
      end
      if round == 1
        get_HTTP_and_code(url, 2, nil)
      end
      if round == 2
        resp = nil
      end
    end
    if !resp.nil? && %w{301 302 307}.include?(resp.code)
      get_HTTP_and_code(resp.header['location'], 0, resp.code)
    else
      if resp.nil?
        # puts 'resp.nil?'
        # puts '??????????'
        return 'empty', 0
      end
      if code.nil?
        # puts resp.code
        # puts '??????????'
        return resp.body, resp.code
      end
      if !code.nil?
        # puts code
        # puts '??????????'
        return resp.body, code
      end
    end
  end

  def url_label(url)
    # puts 'in url label '+@url_hash[url].to_s
    @url_hash[url][0]
  end

  def label_url(child_url, parent_url)
    if @url_hash[child_url].nil?
      if !child_url.ascii_only?
        @url_hash[child_url] = ['untested', parent_url]
      else
        case child_url
        when /mailto:/
          @url_hash[child_url] = ['system', parent_url]
        when /\s/
          @url_hash[child_url] = ['untested', parent_url]
        when /\.pdf$/
          @url_hash[child_url] = ['system', parent_url]
        when /\.svg$/
          @url_hash[child_url] = ['system', parent_url]
        when /\.ico$/
          @url_hash[child_url] = ['system', parent_url]
        when /\.png$/
          @url_hash[child_url] = ['system', parent_url]
        when /\.css$/
          @url_hash[child_url] = ['system', parent_url]
        when /\.jpg$/
          @url_hash[child_url] = ['system', parent_url]
        when /^www./
          @url_hash[child_url] = ['untested', parent_url]
        when /^\/\/www./
          @url_hash[child_url] = ['untested', parent_url]
        when /^(?!http)/
          label_url(add_domain_to(child_url), parent_url)
        when /^#{@www_key_url}/
          @url_hash[child_url] = ['valid', parent_url]
        when /^#{@non_www_key_url}/
          @url_hash[child_url] = ['valid', parent_url]
        else
          @url_hash[child_url] = ['untested', parent_url]
        end
      end
    end
  end
end
