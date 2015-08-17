require 'seo_check'

class Comfy::Admin::Cms::SeosController < Comfy::Admin::Cms::BaseController
  def index
  end

  def wait
    render 'wait'
  end

  def check
    webpage = 'https://www.clark.de'
    crawler = Crawler.new(webpage)
    @result = crawler.crawl_webpage
  end
end
