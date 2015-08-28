require 'pp'

class SeoChecker
  def initialize(webpage)
    @key_url = webpage
    @url_hash = {}
    @sorted_url_hash = {}
    @attributes_hash = {}
    @sorted_attributes_hash = {}
  end

  def check_seo
    preprocess_urls(@key_url)
    crawl_page
    judge_content
    sort_url_hash
    sort_attributes_hash
    return_all
  end

  def preprocess_urls(key_url)
    prep = PreprocessUrls.new(key_url)
    @url_hash = prep.run

  end

  def crawl_page
    crawl = CrawlPage.new(@url_hash)
    @attributes_hash = crawl.run
  end

  def judge_content
    content = JudgeContent.new(@key_url, @attributes_hash)
    @attributes_hash = content.judge
  end

  def sort_url_hash
    valid_urls = []
    intern_urls = []
    extern_urls = []
    system_urls = []
    error_urls = []
    code_200_urls = []
    redirected_urls = []
    code_error_urls = []
  # @url_hash[child_url] = [label, parent_url, code, doc, child_url.dup]
    @url_hash.each do |url, values|
      case values[0]
      when 'valid'
        valid_urls << [url, values[1]] 
      when 'untested'
        if get_domain(url) == get_domain(@key_url)
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
        redirected_urls << [url, values[1], values[2]] 
      else
        code_error_urls << [url, values[1], values[2]] unless values[0] == 'system'
      end
    end
    @sorted_url_hash['Valid'] = valid_urls
    @sorted_url_hash['Intern'] = intern_urls
    @sorted_url_hash['Extern'] = extern_urls
    @sorted_url_hash['System'] = system_urls
    @sorted_url_hash['Error'] = error_urls
    @sorted_url_hash['Code_200'] = code_200_urls
    @sorted_url_hash['Redirected'] = redirected_urls
    @sorted_url_hash['Code_error'] = code_error_urls
  end

  def get_domain(url)
    url.match(/https?:\/\/(www\.|)(\b\S+)[\.]/)
    $2.to_s
  end

  def sort_attributes_hash
    @attributes_hash.each do |url, attributes|
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
      @sorted_attributes_hash[url] = [new_attributes, attributes.last]
    end
  end

  def return_all
    result = {}
    result[:sorted_attributes_hash] = @sorted_attributes_hash
    result[:sorted_urls_hash] = @sorted_url_hash
    result
  end
end
