class SeoCheck
  def initialize(valid_urls_attributes_hash, key_url)
    @attri = valid_urls_attributes_hash
    @key_url = key_url
  end

  def check_seo
    same_keyword_title_h1_url_description(@attri.dup)
  end

  def same_keyword_title_h1_url_description(dup_attri)
    dup_attri.each do |url, attributes|
      unless url == @key_url
        @keyword_hash = {}
        h1 = attributes[:all_h1_header]
        desc = attributes[:meta_description]
        title = attributes[:title]
        fill_keyword_hash(h1.join( ).split)
        fill_keyword_hash(desc.join( ).split)
        fill_keyword_hash(title.join( ).split)
        fill_keyword_hash(url.split('/'))
        attributes[:four_identical_keywords_in_h1_title_url_description] = @keyword_hash.key(4) || 'nothing found'
        attributes[:three_identical_keywords_in_h1_title_url_description] = @keyword_hash.key(3) || 'nothing found'
        attributes[:all_keywords] = @keyword_hash
        @attri[url] = attributes
      end
    end
  end

  def fill_keyword_hash(input)
    keywords_curr_loop = []
    input.each do |word|
      word = preprocess_keyword(word)
      if (@keyword_hash.has_key? word)
        unless keywords_curr_loop.include? word
          @keyword_hash[word] += 1
          keywords_curr_loop << word
        end
      else
        @keyword_hash[word] = 1
      end
    end
  end

  def preprocess_keyword(word)
    word.downcase!
    case word
    when /ü/
      word.gsub!(/ü/, 'ue')
    when /ä/
      word.gsub!(/ä/, 'ae')
    when /ö/
      word.gsub!(/ö/, 'oe')
    when /(\.|!|\?|,)\z/
      word.gsub!(/(\.|!|\?|,)\z/, '')
    else
      word
    end
  end
end
