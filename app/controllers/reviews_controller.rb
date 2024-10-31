class ReviewsController < ApplicationController

  def index
    @reviews = Review.all.order(:created_at)
  end

  def show
    @review = Review.find(params[:id])
  end

  def create

  end

  def new

  end
  

  def destroy

  end
end
