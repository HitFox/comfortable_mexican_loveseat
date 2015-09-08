require 'rails_helper'

describe 'seo tags spec' do

  before do
    #create site
    site = Comfy::Cms::Site.where(label: 'default', identifier: 'default', hostname: 'localhost', path: '', locale: 'en', is_mirrored: false).first_or_create

    # import fixtures
    ComfortableMexicanSofa::Fixture::Importer.new('default', 'default', :force).import!

    visit '/'
  end

  it 'shows the root page' do
    expect(page).to have_content('Hello world')
  end

end
