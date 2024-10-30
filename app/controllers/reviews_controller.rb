class ReviewsController < ApplicationController

  def index
    @reviews = Review.all
  end

  def show

  end

  def create

  end

  def new
    @review = Review.new
  end

  def destroy

  end
end
