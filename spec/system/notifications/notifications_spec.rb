require 'rails_helper'

RSpec.describe "Recommend", type: :system do
  include Devise::Test::IntegrationHelpers

  before do
    driven_by(:rack_test)
  end

  before(:each) do
    @sender = User.create!(
      first: 'Harry',
      last: 'Potter',
      email: 'hpotter@colgate.edu',
      password: 'colgate13',
      role: :standard,
    )

    @receiver = User.create!(
      first: 'Ron',
      last: 'Weasley',
      email: 'rweasley@colgate.edu',
      password: 'colgate13',
      role: :standard,
    )
  end

  describe "validations" do 
    it "should not allow a sender a reciever to be the same" do

      user = FactoryBot.build(:user)
      notification = FactoryBot.build(:notification, :sender => user, :receiver => user)

      expect(notification.valid?).to be_falsey
      expect(notification.errors[:receiver]).to include("can't be the same as sender")   
    end
  end
end