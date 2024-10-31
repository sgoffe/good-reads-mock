class ReviewsController < ApplicationController

  def index
    @reviews = Review.all.order(:created_at)
  end

  def show

  end

  def create

  end

  def new

  end

  def destroy

  end
end
