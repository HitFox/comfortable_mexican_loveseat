class JudgeContent
  def initialize(key_url, valid_urls_attributes_hash)
    @key_url = key_url
    @attributes = valid_urls_attributes_hash
  end

  def judge
    same_keyword_title_h1_url_description(@attributes.dup)
    color_calculator(@attributes)
  end

  def same_keyword_title_h1_url_description(dup_attri)
    dup_attri.each do |url, attributes|
      at_first = attributes.first
      @color_count = attributes.last
      unless url == @key_url
        @keyword_hash = {}
        h1 = at_first[:headings_all_h1_header]
        desc = at_first[:head_meta_description]
        title = at_first[:head_title]
        fill_keyword_hash(h1.join( ).split)
        fill_keyword_hash(desc.join( ).split)
        fill_keyword_hash(title.join( ).split)
        fill_keyword_hash(url.split('/'))
        at_first[:content_four_identical_keywords_in_h1_title_url_description] = fetch_identical_keys(4)
        at_first[:content_three_identical_keywords_in_h1_title_url_description] = fetch_identical_keys(3)
        at_first[:content_all_keywords] = @keyword_hash
        @attributes[url] = [at_first, attributes[1]+=@color_count]
      end
    end
    @attributes
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
end
