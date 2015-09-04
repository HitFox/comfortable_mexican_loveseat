class PreprocessUrls
  def initialize(key_url)
    @key_url = key_url
    @url_hash = {}
    # later: @url_hash[child_url] = [label, parent_url, code, doc, child_url.dup, redirect_target]
    @child_url_array = []
  end

  def run
    dup_key_url(@key_url)
    url_hash = fill_url_hash(@key_url)
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
    @url_hash
  end

  def get_all_urls_of(parent_url)
    @url_hash[parent_url][4] = check_domain(parent_url)
    begin
      @body = ''
      @code = 0
      @redirect_target_url = nil
      get_HTTP_and_code(@url_hash[parent_url][4].dup, 0, nil)
      @url_hash[parent_url][2] = @code
      if @redirect_target_url
        @url_hash[parent_url][0] = 'untested'
        @url_hash[parent_url][5] = @redirect_target_url
        label_url(@redirect_target_url, 'redirect of-> '+parent_url)
      end
      if url_label(parent_url) == 'valid'
        if @code == '404' || @code == 0
          @url_hash[parent_url][0] = 'untested'
        else
          doc = Nokogiri::HTML(@body)
          @url_hash[parent_url][3] = doc
          doc.xpath('//comment()').remove
          doc.xpath('//@href').each do |child_url|
            unless @child_url_array.include? child_url.to_s
              label_url(child_url.to_s, parent_url)
              @child_url_array << child_url.to_s
            end
          end
        end
      end
    rescue Exception => e
      if e.message
        @url_hash[parent_url][0] = e.message
        @url_hash[parent_url][2] = e.message
        @url_hash[parent_url][3] = 'empty'
        return false
      end
    end
    return true
  end

  def check_domain(target_url, start_url = @key_url)
    new_url = target_url
    unless target_url.match(/^http/)
      cutted_start_url = start_url.match(/(https?:\/\/(www\.|)[^\/]+)/).to_s
      cutted_start_url.sub!(/\w+\z/,'')
      if (@www_key_url || @non_www_key_url) == cutted_start_url
        new_url = add_domain_to(target_url)
      else
        new_url = add_domain_to(target_url, start_url.match(/(https?:\/\/(www\.|)[^\/]+)/).to_s)
      end
    end
    new_url
  end

  def add_domain_to(url, domain_url = @key_url)
    unless url.match(/^\//)
      url = '/'+url
    end
    domain_url+url
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
      redirect_url = resp.header['location']
      new_redirect_url = check_domain(redirect_url, url)
      if @redirect_target_url.nil?
        @redirect_target_url = new_redirect_url
      end
      get_HTTP_and_code(new_redirect_url, 0, resp.code)
    else
      if resp.nil?
        if @body.empty?
          @body = 'empty'
          @code = 0
        end
        return
      end
      if code.nil?
        if @body.empty?
          @body = resp.body
          @code = resp.code
        end
        return
      end
      if !code.nil?
        if @body.empty?
          @body = resp.body
          @code = code
        end
        return
      end
    end
  end

  def url_label(url)
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
