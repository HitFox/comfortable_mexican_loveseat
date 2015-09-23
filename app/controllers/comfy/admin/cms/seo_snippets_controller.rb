class Comfy::Admin::Cms::SeoSnippetsController < Comfy::Admin::Cms::BaseController 

  before_action :build_seo_snippet, :only => [:new, :create]
  before_action :authorize

  def index
    raise NotImplemented, "You should never see this, use Snippet Index instead"
  end

  def new
    render
  end

  def create
    debugger
    @seo_snippet = SeoSnippet.new(params[:seo_snippet])
    return
    # @seo_snippet.create_missing_attributes(params[:number_of_contacts])
    if seo_snippet_enhanced_params_are_valid?(params[:seo_snippet])
      WriteSeoSnippet.write_snippet(params)
      @snippet = @site.snippets.new(params.fetch(:snippet, {}).permit!)
      @snippet.save!
      flash[:success] = I18n.t('comfy.admin.cms.snippets.created')
      redirect_to controller: 'snippets', action: 'edit', id: @snippet
    else
      flash.now[:danger] = 
        @seo_snippet.errors.full_messages
      render :action => :new
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.snippets.creation_failure')
    render :action => :new
  end

protected

  def build_seo_snippet
    @seo_snippet = SeoSnippet.new
  end

  def enhance_seo_snippet(seo_params)
    @seo_snippet.url = seo_params[:url]
    @seo_snippet.label = seo_params[:label]
    @seo_snippet.telephone = seo_params[:telephone]
    @seo_snippet.contact_type_selected = seo_params[:contact_type].blank? ? false : true
  end

  def seo_snippet_enhanced_params_are_valid?(seo_params)
    enhance_seo_snippet(seo_params)
    @seo_snippet.valid?
  end
end
