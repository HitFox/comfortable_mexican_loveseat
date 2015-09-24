module Comfy::CmsHelper

  def comfy_seo_tags
    meta_description = pluck_page_block_content('seo.meta_description')
    meta_index = pluck_page_block_content('seo.meta_index')
    page_title = pluck_page_block_content('seo.page_title')
    parent_page = @cms_page.parent_id.present? ? @cms_page.parent_id : false
    tags = []
    tags << tag('meta', name: 'description', content: meta_description) if meta_description.present?
    tags << tag('meta', name: 'robots', content: 'NOINDEX, FOLLOW') if meta_index.present? && meta_index

    # if no canonical is set, default to URL without any parameters
    href = pluck_page_block_content('seo.canonical_href')
    href = href.present? ? href : request.url.split('?').first
    tags << tag('link', rel: 'canonical', href: href)

    ### Google plus: use meta_description and page title as defaults
    gplus_name = self_or_inherit_metadata('google_plus.name', page_title)
    gplus_description = self_or_inherit_metadata('google_plus.description', meta_description)
    gplus_image = self_or_parent_metafield('google_plus.image')
    tags << tag('meta', itemprop: "name", content: gplus_name) if gplus_name.present?
    tags << tag('meta', itemprop: "description", content: gplus_description) if gplus_description.present?
    tags << tag('meta', itemprop: "image", content: gplus_image) if gplus_image.present?

    ### Twitter Card
    twitter_site = self_or_parent_metafield('twitter.site')
    twitter_creator = self_or_parent_metafield('twitter.creator')
    twitter_image_src = self_or_parent_metafield('twitter.image_src')
    twitter_title = self_or_inherit_metadata('twitter.title', page_title)
    twitter_description = self_or_inherit_metadata('twitter.description', meta_description)
    tags << tag('meta', name: 'twitter:card', content: 'summary_large_image')
    tags << tag('meta', name: 'twitter:site', content: twitter_site) if twitter_site.present?
    tags << tag('meta', name: 'twitter:creator', content: twitter_creator) if twitter_creator.present?
    tags << tag('meta', name: 'twitter:image:src', content: twitter_image_src) if twitter_image_src.present?
    tags << tag('meta', name: 'twitter:title', content: twitter_title) if twitter_title.present?
    tags << tag('meta', name: 'twitter:description', content: twitter_description) if twitter_description.present?

    ### Facebook
    fb_description = self_or_inherit_metadata('facebook.description', meta_description)
    fb_title = self_or_inherit_metadata('facebook.title', page_title)
    fb_type = self_or_parent_metafield('facebook.type')
    fb_image = self_or_parent_metafield('facebook.image')
    fb_admins = self_or_parent_metafield('facebook.admins')
    tags << tag('meta', property: 'og:description', content: fb_description) if fb_description.present?
    tags << tag('meta', property: 'og:title', content: fb_title) if fb_title.present?
    tags << tag('meta', property: 'og:type', content: fb_type) if fb_type.present?
    tags << tag('meta', property: 'og:image', content: fb_image) if fb_image.present?
    tags << tag('meta', property: 'fb:admins', content: fb_admins) if fb_admins.present?

    site_name = Comfy::Cms::Block.where(blockable_id: @cms_site.pages.first.id, blockable_type: 'Comfy::Cms::Page', identifier: 'seo.page_title').pluck(:content).first
    tags << tag('meta', property: 'og:site_name', content: site_name) if site_name.present?
    tags << tag('meta', property: 'og:url', content: request.url.split('?').first)

    return tags.join("\n").html_safe
  end

  def comfy_page_title
    pluck_page_block_content('seo.page_title')
  end

  def self_or_inherit_metadata(block_identifier, metadata)
    content = pluck_page_block_content(block_identifier)
    if content.present?
      return content
    else
      return metadata
    end
  end

  def self_or_parent_metafield(block_identifier, page = @cms_page)
    content = pluck_page_block_content(block_identifier, page)
    if content.present?
      return content
    else
      if page.present?
        return Comfy::Cms::Block.where(identifier: block_identifier, blockable_type: 'Comfy::Cms::Page', blockable_id: page.parent_id).pluck(:content).first
      end
    end
  end

  def pluck_page_block_content(tag, page = @cms_page)
    content = Comfy::Cms::Block.where(identifier: tag, blockable_type: 'Comfy::Cms::Page', blockable_id: page.id).pluck(:content).first
    return (content.present?) ? content : ''
  end

  def flash_css_class(type)
    case type.to_sym
      when :notice, :success then 'alert-success'
      when :alert, :failure then 'alert-danger'
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

  # Content of a snippet. Examples:
  #   cms_snippet_content(:my_snippet)
  #   <%= cms_snippet_content(:my_snippet) do %>
  #     Default content can go here.
  #   <% end %>
  def cms_snippet_content(identifier, cms_site = @cms_site, &block)
    unless cms_site
      host, path = request.host_with_port.downcase, request.fullpath if respond_to?(:request) && request
      cms_site = Comfy::Cms::Site.find_site(host, path)
    end
    return '' unless cms_site

    snippet = cms_site.snippets.find_by_identifier(identifier)

    if !snippet && block_given?
      snippet = cms_site.snippets.create(
        :identifier => identifier,
        :label      => identifier.to_s.titleize,
        :content    => capture(&block)
      )
    end

    snippet ? snippet.content : ''
  end

  # Same as cms_snippet_content but cms tags will be expanded
  def cms_snippet_render(identifier, cms_site = @cms_site, &block)
    return '' unless cms_site
    content = cms_snippet_content(identifier, cms_site, &block)
    render :inline => ComfortableMexicanSofa::Tag.process_content(
      cms_site.pages.build, ComfortableMexicanSofa::Tag.sanitize_irb(content)
    )
  end

  # Content of a page block. This is how you get content from page:field
  # Example:
  #   cms_block_content(:left_column, CmsPage.first)
  #   cms_block_content(:left_column) # if @cms_page is present
  def cms_block_content(identifier, blockable = @cms_page)
    tag = blockable && (block = blockable.blocks.find_by_identifier(identifier)) && block.tag
    return '' unless tag
    tag.content
  end

  # For those times when we need to render content that shouldn't be renderable
  # Example: {{cms:field}} tags
  def cms_block_content_render(identifier, blockable = @cms_page)
    tag = blockable && (block = blockable.blocks.find_by_identifier(identifier)) && block.tag
    return '' unless tag
    render :inline => ComfortableMexicanSofa::Tag.process_content(blockable, tag.content)
  end

  # Same as cms_block_content but with cms tags expanded
  def cms_block_render(identifier, blockable = @cms_page)
    tag = blockable && (block = blockable.blocks.find_by_identifier(identifier)) && block.tag
    return '' unless tag
    render :inline => ComfortableMexicanSofa::Tag.process_content(blockable, tag.render)
  end

  # Wrapper to deal with Kaminari vs WillPaginate
  def comfy_paginate(collection)
    return unless collection
    if defined?(WillPaginate)
      will_paginate collection
    elsif defined?(Kaminari)
      paginate collection, :theme => 'comfy'
    end
  end
end
