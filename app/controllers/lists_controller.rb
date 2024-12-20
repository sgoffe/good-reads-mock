class ListsController < ApplicationController
    
    
    # def index # just for user_lists (show all lists? do i want this?)
    #     if params[:user_id] # a user's list (user_lists)
    #         user = User.find(params[:user_id])
    #         @lists = user.lists.order(updated_at: :desc)
    #     elsif params[:book_id] # lists a book has been added to (book_lists) - no route currently
    #         book = Book.find(params[:book_id])
    #         @lists = book.lists
    #     else # (lists) - no route currently
    #         @lists = List.all
    #     end
    # end

    # def new
    #     @list = List.new
    # end

    def create
        if !current_user.nil?
            @list = List.new(title: "Untitled List")
            
            @list.user = current_user
            if @list.save
                redirect_to profile_path, notice: 'List created successfully'
            else
                flash[:alert] = 'List could not be created'
                render 'users/profile', status: :unprocessable_content     # FIXME START HERE
            end
        end
    end

    def edit
        @list = List.find(params[:id])
    end

    def update
        @list = List.find(params[:id])
        if @list.update(create_update_params)
            redirect_to profile_path, notice: 'List updated successfully'
        else
            flash[:alert] = 'List could not be updated'
            render :edit, status: :unprocessable_content    # FIXME
        end
    end
    
    def destroy
        begin
          @list = List.find(params[:id])
          @list.destroy
          redirect_to profile_path, notice: 'List deleted successfully'
        rescue ActiveRecord::RecordNotFound
          flash[:alert] = 'List not found'
          redirect_to profile_path
        rescue StandardError => e
          flash[:alert] = 'Error deleting list'
          redirect_to profile_path
        end
      end
    
    # def show
    #     @list = List.find(params[:list_id])
    # end

    def add_favorite
        @book = Book.find(params[:id])
        if current_user
            if current_user.lists[0]
                current_user.lists[0].books << @book
                redirect_to '/', notice: "#{@book.title} added to favorites"
            end
        end
    end

private
    def create_update_params
        params.require(:list).permit(:title)
    end
end
