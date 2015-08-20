module Comfy::CmsHelper

  def comfy_seo_tags
    tags = []
    tags << tag('meta', name: 'description', content: cms_block_content('seo.meta_description')) if cms_block_content('seo.meta_description').present?
    tags << tag('meta', name: 'robots', content: 'NOINDEX, FOLLOW') if cms_block_content('seo.meta_index').present? && cms_block_content('seo.meta_index')

    # if no canonical is set, default to URL without any parameters
    href = cms_block_content('seo.canonical_href').present? ? cms_block_content('seo.canonical_href') : request.url.split('?').first
    tags << tag('link', rel: 'canonical', href: href)
    #Google plus
    tags << tag('meta', itemprop: "name", content: cms_block_content('google_plus.name')) if cms_block_content('google_plus.name').present?
    tags << tag('meta', itemprop: "description", content: cms_block_content('google_plus.description')) if cms_block_content('google_plus.description').present?
    tags << tag('meta', itemprop: "image", content: cms_block_content('google_plus.image')) if cms_block_content('google_plus.image').present?
    #Twitter Card
    tags << tag('meta', name: 'twitter:card', content: cms_block_content('twitter.card')) if cms_block_content('twitter.card').present?
    tags << tag('meta', name: 'twitter:site', content: cms_block_content('twitter.site')) if cms_block_content('twitter.site').present?
    tags << tag('meta', name: 'twitter:title', content: cms_block_content('twitter.title')) if cms_block_content('twitter.title').present?
    tags << tag('meta', name: 'twitter:description', content: cms_block_content('twitter.description')) if cms_block_content('twitter.description').present?
    tags << tag('meta', name: 'twitter:creator', content: cms_block_content('twitter.creator')) if cms_block_content('twitter.creator').present?
    tags << tag('meta', name: 'twitter:image:src', content: cms_block_content('twitter.image_src')) if cms_block_content('twitter.image_src').present?
    #Facebook
    tags << tag('meta', property: 'og:title', content: cms_block_content('facebook.title')) if cms_block_content('facebook.title').present?
    tags << tag('meta', property: 'og:type', content: cms_block_content('facebook.type')) if cms_block_content('facebook.type').present?
    tags << tag('meta', property: 'og:url', content: cms_block_content('facebook.url')) if cms_block_content('facebook.url').present?
    tags << tag('meta', property: 'og:image', content: cms_block_content('facebook.image')) if cms_block_content('facebook.image').present?
    tags << tag('meta', property: 'og:description', content: cms_block_content('facebook.description')) if cms_block_content('facebook.description').present?
    tags << tag('meta', property: 'og:site_name', content: cms_block_content('facebook.site_name')) if cms_block_content('facebook.site_name').present?
    tags << tag('meta', property: 'article:published_time', content: cms_block_content('facebook.published_time')) if cms_block_content('facebook.published_time').present?
    tags << tag('meta', property: 'article:modified_time', content: cms_block_content('facebook.modified_time')) if cms_block_content('facebook.modified_time').present?
    tags << tag('meta', property: 'article:section', content: cms_block_content('facebook.section')) if cms_block_content('facebook.section').present?
    tags << tag('meta', property: 'article:tag', content: cms_block_content('facebook.tag')) if cms_block_content('facebook.tag').present?
    tags << tag('meta', property: 'fb:admins', content: cms_block_content('facebook.admins')) if cms_block_content('facebook.admins').present?

    return tags.join("\n").html_safe
  end

  def comfy_page_title
    cms_block_content('seo.page_title')
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
