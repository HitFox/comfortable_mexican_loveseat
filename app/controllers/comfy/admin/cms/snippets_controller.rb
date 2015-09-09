class Comfy::Admin::Cms::SnippetsController < Comfy::Admin::Cms::BaseController

  before_action :build_snippet, :only => [:new, :create]
  before_action :load_snippet,  :only => [:edit, :update, :destroy]
  before_action :authorize

  def index
    return redirect_to :action => :new if @site.snippets.count == 0
    @snippets = @site.snippets.includes(:categories).for_category(params[:category])
  end

  def new
    if params[:seo]
      @seo = true
    end
      render
  end

  def edit
    if params[:seo]
      @seo = true
    end
    @snippet.attributes = snippet_params
  end

  def create
    if params['commit'] == 'Create SEO Snippet'
      write_seo_snippet
      build_snippet
      @snippet.save!
      flash[:success] = I18n.t('comfy.admin.cms.snippets.created')
      redirect_to :action => :edit, :id => @snippet, seo: @seo = true
    else
      @snippet.save!
      flash[:success] = I18n.t('comfy.admin.cms.snippets.created')
      redirect_to :action => :edit, :id => @snippet
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.snippets.creation_failure')
    if  params["commit"] == 'Create SEO Snippet'
      render :action => :new, seo: @seo = true
    else
      render :action => :new
    end
  end

  def update
    @snippet.update_attributes!(snippet_params)
    flash[:success] = I18n.t('comfy.admin.cms.snippets.updated')
    redirect_to :action => :edit, :id => @snippet
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.snippets.update_failure')
    render :action => :edit
  end

  def destroy
    @snippet.destroy
    flash[:success] = I18n.t('comfy.admin.cms.snippets.deleted')
    redirect_to :action => :index
  end

  def reorder
    (params[:comfy_cms_snippet] || []).each_with_index do |id, index|
      ::Comfy::Cms::Snippet.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

protected

  def build_snippet
    @snippet = @site.snippets.new(snippet_params)
  end

  def load_snippet
    @snippet = @site.snippets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.snippets.not_found')
    redirect_to :action => :index
  end

  def snippet_params
    params.fetch(:snippet, {}).permit!
  end

  def write_seo_snippet
    WriteSeoSnippet.write_snippet(params)
  end
end
