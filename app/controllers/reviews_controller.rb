class ReviewsController < ApplicationController

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
    if !current_user.nil?
      @book = Book.find(params[:book_id])
      @review = Review.new(create_update_params)
  
      @review.user = current_user
      @book.reviews << @review

      if @review.save
        redirect_to book_path(@book), notice: 'Review created successfully'
      end
    else
      flash[:alert] = 'Review could not be created'
      render :new, status: :unprocessable_content
    end
  end
  
  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(create_update_params)
      redirect_to review_path(@review.id), notice: 'Review updated successfully'
    else
      flash[:alert] = 'Review could not be edited'
      render :edit, status: :unprocessable_content
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
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Review not found'
      redirect_to reviews_path
    rescue StandardError => e
      puts e
      flash[:alert] = 'Error deleting review'
      render :show
    end
  end

private 
  def create_update_params
    # if !params[:book].nil?
    #   @book = Book.find(params[:book])
    # end
    # if !params[:book_id].nil?
    #   params[:book_id] = @books.find(params[:book_id])
    # end
    params.require(:review).permit(:review_text, :rating)
  end
end
