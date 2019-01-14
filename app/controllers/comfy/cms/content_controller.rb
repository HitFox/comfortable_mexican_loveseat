class Comfy::Cms::ContentController < Comfy::Cms::BaseController

  # Authentication module must have `authenticate` method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize

  before_action :load_seeds
  before_action :load_cms_page,
                :authenticate,
                :only => :show

  rescue_from ActiveRecord::RecordNotFound, :with => :page_not_found

  def show

    if @cms_page.target_page.present?
      redirect_to @cms_page.target_page.url(:relative)
    else
      respond_to do |format|
        format.html { render_page }
        format.json { render :json => @cms_page }
      end
    end
  end

  def render_sitemap
    render
  end

protected

  def render_page(status = 200)
    if @cms_layout = @cms_page.layout
      app_layout = (@cms_layout.app_layout.blank? || request.xhr?) ? false : @cms_layout.app_layout
      render  :inline       => @cms_page.content_cache,
              :layout       => app_layout,
              :status       => status,
              :content_type => mime_type
    else
      render :text => I18n.t('comfy.cms.content.layout_not_found'), :status => 404
    end
  end

  # it's possible to control mimetype of a page by creating a `mime_type` field
  def mime_type
    mime_block = @cms_page.blocks.find_by_identifier(:mime_type)
    mime_block && mime_block.content || 'text/html'
  end

  def load_seeds
    return unless ComfortableMexicanSofa.config.enable_seeds

    controllers = %w[layouts pages snippets files].collect { |c| "comfy/admin/cms/" + c }
    if controllers.member?(params[:controller]) && params[:action] == "index"
      ComfortableMexicanSofa::Seeds::Importer.new(@site.identifier).import!
      flash.now[:warning] = I18n.t("comfy.admin.cms.base.seeds_enabled")
    end
  end


  def load_cms_page

    page = @cms_site.pages.published.find_by_full_path("/#{params[:cms_path]}")

    if page.present?
      @cms_page = page
    else

      old_page = Comfy::Cms::Block.where(identifier: 'seo.old_page_url').where('content LIKE ?', "%#{params[:cms_path].to_s}%").pluck(:content, :blockable_id, :blockable_type).first

      if old_page.present?
        if old_page.last == "Comfy::Cms::Page"
          new_page = Comfy::Cms::Page.find_by(id: old_page.second)

          if new_page.present?
            redirect_to new_page.url(:relative), status: 301

            return
          end
        end
      end

      page_not_found
    end
  end

  def page_not_found
    @cms_page = @cms_site.pages.published.find_by_full_path!('/404')

    respond_to do |format|
      format.html { render_page(404) }
    end
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new("Page Not Found at: \"#{params[:cms_path]}\"")
  end
end
