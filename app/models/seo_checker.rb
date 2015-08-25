require 'pp'

class SeoChecker
  def initialize(webpage)
    @key_url = webpage
    @url_hash = {}
    @attributes_hash = {}
    @system_urls_array = []
    @untested_urls_array = []
    @error_urls_hash = {}
  end

  def check_seo
    preprocess_urls(@key_url)
    crawl_page
    judge_content
    divide_url_hash
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

  def divide_url_hash
    @url_hash.each do |url, values|
      if url != @key_url
        case values.first
        when 'valid'
          #@valid_urls_array << [url, values[1]] 
        when 'untested'
          @untested_urls_array << [url, values[1]]
        when 'system'
          @system_urls_array << [url, values[1]]
        else
          @error_urls_hash[url] = values
        end
      end
    end
  end

  def return_all
    result = {}
    result[:attributes_hash] = @attributes_hash
    result[:system_urls_array] = @system_urls_array
    result[:untested_urls_array] = @untested_urls_array
    #result[:not_200_http_response_urls] = @http_response_urls_array
    result
  end

end
