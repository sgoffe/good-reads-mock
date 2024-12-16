class ListsController < ApplicationController
    
    
    def index # just for user_lists (show all lists? do i want this?)
        # if current_user
        #     @lists = current_user.lists.all
        # end
        # @lists = [List.new]
        user = User.find(params[:user_id])
        @lists = user.lists
    end

    # def index # just for user_lists- create custom route instead of to index
       
    # end

    def new
        
    end

    def create
        
    end

    def edit
        
    end

    def show
        @list = List.find(params[:list_id])
    end

    def update
        
    end
    
    def destroy
        
    end
end
