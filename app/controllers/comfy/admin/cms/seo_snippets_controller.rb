class Comfy::Admin::Cms::SeoSnippetsController < Comfy::Admin::Cms::BaseController 

  before_action :authorize

  def index
    raise NotImplementedError, "You should never see this, use Snippet Index instead"
  end

  def new
    @seo_snippet = SeoSnippet.new
    render
  end

  def create
    @seo_snippet = SeoSnippet.new(params[:seo_snippet])
    if seo_snippet_enhanced_params_are_valid?(params[:seo_snippet])
      WriteSeoSnippet.write_snippet(params)
      @snippet = @site.snippets.new(params.fetch(:snippet, {}).permit!)
      @snippet.save!
      flash[:success] = I18n.t('comfy.admin.cms.snippets.created')
      redirect_to controller: 'snippets', action: 'edit', id: @snippet
    else
      array=[]
      @seo_snippet.errors.messages.each do |error_key, error_message|
        array << I18n.t('seo_snippet.'+error_key.to_s+'.'+error_message.join)
      end
      flash.now[:danger] = array.join(', ')
      render :action => :new
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.snippets.creation_failure')
    render :action => :new
  end

protected

  def enhance_seo_snippet(seo_params)
    @seo_snippet.url = seo_params[:url]
    @seo_snippet.label = seo_params[:label]
  end

  def validate_corporate_contacts
    contacts_error_hash = @seo_snippet.corporate_contacts_validator
    unless contacts_error_hash.empty?
      contacts_error_hash.each do |error_name, error_message|
        @seo_snippet.errors.add(error_name, error_message)
      end
    end
  end

  def seo_snippet_enhanced_params_are_valid?(seo_params)
    enhance_seo_snippet(seo_params)
    # .valid? overrides validate_corporate_contacts, so don't switch the order!
    @seo_snippet.valid?
    validate_corporate_contacts
    return @seo_snippet.errors.empty?
  end
end
