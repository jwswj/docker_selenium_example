require 'rails_helper'

RSpec.describe 'test', 'the homepage', type: :feature do
  it 'can view', js: true do
    visit root_path
    expect(page).to have_content('Hello')
  end
end
