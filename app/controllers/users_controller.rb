require 'ostruct'

class UsersController < ApplicationController

  def index
    @users = User.all.order(:first)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def library
    @user = User.find(params[:id])
    params[:source] ||= 'seeded_books'
    params[:page] = params[:page].to_i > 0 ? params[:page].to_i : 1
    @per_page = 10
  
    # Only fetch books reviewed by the user
    reviewed_books = @user.reviews.includes(:book).map(&:book).uniq
  
    if params[:source] == 'google_books'
      # Google Books source does not apply to the library, skip
      @books = []
      @has_more_pages = false
    else
      @books = Kaminari.paginate_array(reviewed_books).page(params[:page]).per(@per_page)
      @has_more_pages = @books.current_page < @books.total_pages
    end
  
    # Search query filtering
    if params[:query].present? && params[:query].length > 2
      @query = params[:query]
      @books = @books.select do |book|
        book.title.downcase.include?(@query.downcase) ||
        book.author.downcase.include?(@query.downcase)
      end
      @query_filt = params[:query]
    end
  
    # Rating filtering
    if params[:rating].present?
      @books = @books.select do |book|
        book.reviews.average(:rating).to_f >= params[:rating].to_f
      end
      @rating_filt = params[:rating]
    end
  
    # Genre filtering
    if params[:genre].present?
      @books = @books.select do |book|
        book.genre.to_s.downcase.include?(params[:genre].downcase)
      end
      @genre_filt = params[:genre]
    end
  
    # Apply sorting if sort param is provided
    if params[:sort].present?
      @books = case params[:sort]
               when 'title ASC' then @books.sort_by(&:title)
               when 'title DESC' then @books.sort_by(&:title).reverse
               when 'rating DESC' then @books.sort_by { |book| -(book.reviews.average(:rating).to_f || 0) }
               when 'rating ASC' then @books.sort_by { |book| (book.reviews.average(:rating).to_f || 0) }
               when 'author ASC' then @books.sort_by(&:author)
               when 'author DESC' then @books.sort_by(&:author).reverse
               when 'publish_date DESC' then @books.sort_by(&:publish_date).reverse
               when 'publish_date ASC' then @books.sort_by(&:publish_date)
               else @books
               end
      @sort_filt = params[:sort]
    end
  
    # Sort options
    @sorts = [
      ["Title - A to Z", "title ASC"],
      ["Title - Z to A", "title DESC"],
      ["Rating - Highest to Lowest", "rating DESC"],
      ["Rating - Lowest to Highest", "rating ASC"],
      ["Author - A to Z", "author ASC"],
      ["Author - Z to A", "author DESC"],
      ["Release Date - Newest to Oldest", "publish_date DESC"],
      ["Release Date - Oldest to Newest", "publish_date ASC"]
    ]
  end

  def admin
    @user = User.find(params[:id])
    @users = User.all
    if (params[:first_query].present?)
      @users = @users.select{|user| user[:first].to_s.downcase.include?(params[:first_query].downcase)}
    end
    if (params[:last_query].present?)
      @users = @users.select{|user| user[:last].to_s.downcase.include?(params[:last_query].downcase)}
    end
    if (params[:email_query].present?)
      @users = @users.select{|user| user[:email].to_s.downcase.include?(params[:email_query].downcase)}
    end
  end

  def admin_moderate
    @user = User.find(params[:id])
    @reviews = @user.reviews
  end

  def update
    @user = User.find(params[:id])
    if @user.update(create_update_params)
      redirect_to user_path(@user)
      #add notices and flashes to everything
    else 
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.friendships.destroy_all
    if @user.destroy
      if (params[:from_admin].present? && params[:from_admin])
        redirect_to user_admin_path(1)
      else
        redirect_to books_path
      end
    else
      ##error message
    end

  end

private
  def create_update_params
    params.require(:user).permit(:first, :last, :email, :bio)
  end

end
