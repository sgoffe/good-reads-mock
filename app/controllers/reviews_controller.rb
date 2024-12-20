class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy, :edit]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_bad_id

  def index
    @reviews = Review.all.order(created_at: :desc)
  end

  def show
    @review = Review.find(params[:id])
  end

  def new 
    @review = Review.new
    @book = Book.find(params[:book_id])
  end

  def create
    @book = Book.find(params[:book_id])
    @review = Review.new(create_update_params)

    @review.user = current_user
    @book.reviews << @review

    if @review.save
      redirect_to book_path(@book), notice: 'Review created successfully'
    else
      flash[:alert] = 'Review could not be created'
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    @book = Book.find(params[:book_id])
    if @review.update(create_update_params)
      redirect_to review_path(@review.id), notice: 'Review updated successfully'
    else
      flash[:alert] = 'Review could not be edited'
    end
    
  end

  def destroy
    begin
      @review = Review.find(params[:id])
      @review.destroy
      if (params[:from_admin].present? && params[:from_admin])
        redirect_to user_admin_path(current_user.id)
      else 
        redirect_to books_path, notice: 'Review deleted successfully'
      end
    rescue StandardError => e
      puts e
      flash[:alert] = 'Error deleting review'
      render :show
    end
  end

private 
  def create_update_params
    params.require(:review).permit(:review_text, :rating)
  end

  def handle_bad_id
    flash[:alert] = 'Invalid Review'
    redirect_to books_path
  end
end
