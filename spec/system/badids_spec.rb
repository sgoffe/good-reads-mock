require 'rails_helper'

RSpec.describe "Badids", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "displays an error for an invalid review" do
    visit '/reviews/1000'
    expect(page.text).to match(/Invalid Review/)
  end
end