# spec/tasks/populate_books_spec.rb

require 'rails_helper'
require 'rake'

RSpec.describe 'populate:books', type: :task do
  before do
    Rake.application.load_rakefile
    Rake::Task['populate:books'].reenable
  end

  it 'populates the database with books' do
    expect { Rake::Task['populate:books'].invoke }.to change { Book.count }.by_at_least(1)
    expect(Book.count).to be > 0
  end
end
