class FriendshipsController < ApplicationController


    def create
        @friendship = Friendship.new(user_id: params[:user_id], friend_id: params[:friend_id])
        if @friendship.save
            flash[:notice] = "Book created successfully"
            redirect_to books_path
        else
            flash[:alert] = "Book could not be created" 
            render :new, status: :unprocessable_entity
        end
    end




end