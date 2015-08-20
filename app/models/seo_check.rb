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
      at_first = attributes.first
      @color_count = attributes.last
      unless url == @key_url
        @keyword_hash = {}
        h1 = at_first[:all_h1_header]
        desc = at_first[:meta_description]
        title = at_first[:title]
        fill_keyword_hash(h1.join( ).split)
        fill_keyword_hash(desc.join( ).split)
        fill_keyword_hash(title.join( ).split)
        fill_keyword_hash(url.split('/'))
        at_first[:four_identical_keywords_in_h1_title_url_description] = fetch_identical_keys(4)
        at_first[:three_identical_keywords_in_h1_title_url_description] = fetch_identical_keys(3)
        at_first[:all_keywords] = @keyword_hash
        @attri[url] = [at_first, attributes[1]+=@color_count]
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

  def fetch_identical_keys(number)
    temp_key_array = []
    temp_key_hash = @keyword_hash.dup
    while temp_key_hash.has_value?(number)
      key_word = temp_key_hash.key(number)
      temp_key_hash.delete(key_word)
      temp_key_array << key_word
    end
    if temp_key_array.empty?
      @color_count += 5 if number == 4
      return 'nothing found'
    else
      return temp_key_array
    end
  end
end
