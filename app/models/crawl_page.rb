class CrawlPage
  def initialize(url_hash)
    @url_hash = url_hash
  end

  def run
    fill_attributes_hash
  end

  def fill_attributes_hash
    attributes_hash = {}
    # Fetch and parse HTML document
    @url_hash.each do |url, values|
      if values.first == 'valid'
        # puts 'url '+url
        # puts 'values0 '+values[0]
        # puts 'values1 '+values[1]
        # puts 'values2 '+values[2]
        # #puts 'values3 '+values[3]
        # puts 'values3 '+values[4]
        doc = values[3]
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

        doc.xpath('//h1').each do |header|
          all_h1_header << header.text
        end
        doc.xpath('//h2').each do |header|
          all_h2_header << header.text
        end
        doc.xpath('//h3').each do |header|
          all_h3_header << header.text
        end
        doc.xpath('//h4').each do |header|
          all_h4_header << header.text
        end
        doc.xpath('//h5').each do |header|
          all_h5_header << header.text
        end
        doc.xpath('//h6').each do |header|
          all_h6_header << header.text
        end

        doc.xpath('//title').each do |t|
          title << t.text
        end

        doc.xpath('//meta[@name="description"]').each do |description|
          meta_description << description.to_s
        end

        doc.xpath('//a[@href]').each do |link|
          all_links << link
        end

        doc.xpath('//p').each do |p|
          p_tag << p.text
        end
        check_length(p_tag)

        doc.xpath('//link[@rel="canonical"]').each do |can_links|
          canon_links << can_links
        end

        doc.xpath('//img').each do |pic|
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
        attributes_hash[url] = [result_hash, @count_for_color_of_url]
      end
    end
    attributes_hash
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
end
