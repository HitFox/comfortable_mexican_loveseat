module Comfy::CmsHelper

  def comfy_seo_tags
    page_block_contents = Comfy::Cms::Fragment.where(blockable_type: 'Comfy::Cms::Page', blockable_id: @cms_page.id).pluck(:identifier, :content)
    meta_description = search_page_block_contents('seo.meta_description', page_block_contents)
    meta_index = search_page_block_contents('seo.meta_index', page_block_contents)
    page_title = search_page_block_contents('seo.page_title', page_block_contents)
    parent_page = @cms_page.parent_id.present? ? @cms_page.parent_id : false
    tags = []
    tags << tag('meta', name: 'description', content: meta_description) if meta_description.present?
    tags << tag('meta', name: 'robots', content: 'NOINDEX, FOLLOW') if meta_index.present? && meta_index

    # if no canonical is set, default to URL without any parameters
    href = search_page_block_contents('seo.canonical_href')
    href = href.present? ? href : request.url.split('?').first
    tags << tag('link', rel: 'canonical', href: href)

    ### Google plus: use meta_description and page title as defaults
    gplus_name = self_or_inherit_metadata('google_plus.name', page_title, page_block_contents)
    gplus_description = self_or_inherit_metadata('google_plus.description', meta_description, page_block_contents)
    gplus_image = self_or_parent_metafield('google_plus.image', @cms_page, page_block_contents)
    tags << tag('meta', itemprop: "name", content: gplus_name) if gplus_name.present?
    tags << tag('meta', itemprop: "description", content: gplus_description) if gplus_description.present?
    tags << tag('meta', itemprop: "image", content: gplus_image) if gplus_image.present?

    ### Twitter Card
    twitter_site = self_or_parent_metafield('twitter.site', @cms_page, page_block_contents)
    twitter_creator = self_or_parent_metafield('twitter.creator', @cms_page, page_block_contents)
    twitter_image_src = self_or_parent_metafield('twitter.image_src', @cms_page, page_block_contents)
    twitter_title = self_or_inherit_metadata('twitter.title', page_title, page_block_contents)
    twitter_description = self_or_inherit_metadata('twitter.description', meta_description, page_block_contents)
    tags << tag('meta', name: 'twitter:card', content: 'summary_large_image')
    tags << tag('meta', name: 'twitter:site', content: twitter_site) if twitter_site.present?
    tags << tag('meta', name: 'twitter:creator', content: twitter_creator) if twitter_creator.present?
    tags << tag('meta', name: 'twitter:image:src', content: twitter_image_src) if twitter_image_src.present?
    tags << tag('meta', name: 'twitter:title', content: twitter_title) if twitter_title.present?
    tags << tag('meta', name: 'twitter:description', content: twitter_description) if twitter_description.present?

    ### Facebook
    fb_description = self_or_inherit_metadata('facebook.description', meta_description, page_block_contents)
    fb_title = self_or_inherit_metadata('facebook.title', page_title, page_block_contents)
    fb_type = self_or_parent_metafield('facebook.type', @cms_page, page_block_contents)
    fb_image = self_or_parent_metafield('facebook.image', @cms_page, page_block_contents)
    fb_admins = self_or_parent_metafield('facebook.admins', @cms_page, page_block_contents)
    tags << tag('meta', property: 'og:description', content: fb_description) if fb_description.present?
    tags << tag('meta', property: 'og:title', content: fb_title) if fb_title.present?
    tags << tag('meta', property: 'og:type', content: fb_type) if fb_type.present?
    tags << tag('meta', property: 'og:image', content: fb_image) if fb_image.present?
    tags << tag('meta', property: 'fb:admins', content: fb_admins) if fb_admins.present?

    site_name = Comfy::Cms::Fragment.where(blockable_id: @cms_site.pages.first.id, blockable_type: 'Comfy::Cms::Page', identifier: 'seo.page_title').pluck(:content).first
    tags << tag('meta', property: 'og:site_name', content: site_name) if site_name.present?
    tags << tag('meta', property: 'og:url', content: request.url.split('?').first)

    return tags.join("\n").html_safe
  end

  def comfy_page_title
    pluck_page_block_content('seo.page_title')
  end

  def self_or_inherit_metadata(block_identifier, metadata, page_block_contents = [])
    content = search_page_block_contents(block_identifier, page_block_contents)
    if content.present?
      return content
    else
      return metadata
    end
  end

  def self_or_parent_metafield(block_identifier, page = @cms_page, page_block_contents = [])
    content = search_page_block_contents(block_identifier, page_block_contents)
    if content.present?
      return content
    else
      if page.present?
        return Comfy::Cms::Fragment.where(identifier: block_identifier, blockable_type: 'Comfy::Cms::Page', blockable_id: page.parent_id).pluck(:content).first
      end
    end
  end

  def search_page_block_contents(identifier, page_block_contents = [])
    result = page_block_contents.select { |a| a.first == identifier }
    result.empty? ? '' : result.first.last
  end

  def pluck_page_block_content(tag, page = @cms_page)
    content = Comfy::Cms::Fragment.where(identifier: tag, blockable_type: 'Comfy::Cms::Page', blockable_id: page.id).pluck(:content).first
    return (content.present?) ? content : ''
  end

  def flash_css_class(type)
    case type.to_sym
      when :notice, :success then 'alert-success'
      when :alert, :failure then 'alert-danger'
    end
  end

  # Raw content of a page fragment. This is how you get content from unrenderable
  # tags like {{cms:fragment meta, render: false}}
  # Example:
  #   cms_fragment_content(:left_column, CmsPage.first)
  #   cms_fragment_content(:left_column) # if @cms_page is present
  def cms_fragment_content(identifier, page = @cms_page)
    frag = page&.fragments&.detect { |f| f.identifier == identifier.to_s }
    return "" unless frag
    case frag.tag
    when "date", "datetime"
      frag.datetime
    when "checkbox"
      frag.boolean
    when "file", "files"
      frag.attachments
    else
      frag.content
    end
  end

  # Same as cms_fragment_content but with cms tags expanded and rendered. Use
  # it only if you know you got more stuff in the fragment content other than
  # text because this is a potentially expensive call.
  def cms_fragment_render(identifier, page = @cms_page)
    node = page.fragment_nodes.detect { |n| n.identifier == identifier.to_s }
    return "" unless node
    node.renderable = true
    render inline: page.render([node])
  end

  # Raw content of a snippet.
  # Example:
  #   cms_snippet_content(:my_snippet)
  def cms_snippet_content(identifier, cms_site = @cms_site)
    cms_site ||= cms_site_detect
    snippet = cms_site&.snippets&.find_by_identifier(identifier)
    return "" unless snippet
    snippet.content
  end

  # Same as cms_snippet_content but cms tags will be expanded. Note that there
  # is no page context, so snippet cannot contain fragment tags.
  def cms_snippet_render(identifier, cms_site = @cms_site)
    cms_site ||= cms_site_detect
    snippet = cms_site&.snippets&.find_by_identifier(identifier)
    return "" unless snippet
    r = ComfortableMexicanSofa::Content::Renderer.new(snippet)
    render inline: r.render(r.nodes(r.tokenize(snippet.content)))
  end

  def cms_site_detect
    host = request.host_with_port.downcase
    path = request.fullpath
    Comfy::Cms::Site.find_site(host, path)
  end

  # Wrapper to deal with Kaminari vs WillPaginate
  def comfy_paginate(collection)
    return unless collection
    if defined?(WillPaginate)
      will_paginate collection
    elsif defined?(Kaminari)
      paginate collection, theme: "comfy"
    end
  end

  # Wrapper around ComfortableMexicanSofa::FormBuilder
  def comfy_form_for(record, options = {}, &proc)
    options[:builder] = ComfortableMexicanSofa::FormBuilder
    options[:layout] ||= :horizontal
    bootstrap_form_for(record, options, &proc)
  end

  # Injects some content somewhere inside cms admin area
  def cms_hook(name, options = {})
    ComfortableMexicanSofa::ViewHooks.render(name, self, options)
  end
end
