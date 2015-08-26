require 'seo_checker'
require 'Preprocess_urls'
require 'crawl_page'
require 'judge_content'


class Comfy::Admin::Cms::SeosController < Comfy::Admin::Cms::BaseController
  def index
  end

  def wait
    render 'wait'
  end

  def check
    webpage = 'https://www.billfront.com'
    now = Time.now
    check = SeoChecker.new(webpage)
    @result = check.check_seo
    ending = Time.now
    puts now.to_s+' till '+ending.to_s
  end
end
