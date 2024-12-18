require 'rails_helper'

RSpec.describe List, type: :model do
  it "should respond to the required fields" do
    l = List.new
    expect(l).to respond_to(:user_id)
    expect(l).to respond_to(:title)
  end
end
