class ReviewsController < ApplicationController

  def index
    @reviews = Review.all.order(created_at: :desc)
  end

  def show
    @review = Review.find(params[:id])
  end

  def new 
    @review = Review.new
    @user = current_user
  end

  def create


    # @review = Review.new(user_id: params[:user_id], book_id: params[:book_id])


    if !current_user.nil?
      @review = Review.new(create_update_params)
      @review.book = Book.find_by_search_string() #FIXME
        (@sight).reviews << @review
      if review.save
        redirect_to reviews_path, notice: 'Review created successfully'
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
      redirect_to review_path(@review), notice: 'Review updated successfully'
    else
      flash[:alert] = 'Review could not be edited'
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    begin
      @review = Review.find(params[:id])
      @review.destroy
      redirect_to reviews_path, notice: 'Review deleted successfully'
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Review not found'
      redirect_to reviews_path
    rescue StandardError => e
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
    params.require(:review).permit(:user_id, :book_id, :review_text, :rating) #, :book_id
  end
end
