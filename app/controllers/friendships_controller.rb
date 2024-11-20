class FriendshipsController < ApplicationController


    def find
        @users = User.all
    end

    def create
        @friendship = Friendship.new(user_id: params[:user_id], friend_id: params[:friend_id])
        if @friendship.save
            flash[:notice] = "Friend successfully added"
            redirect_to books_path
        else
            flash[:alert] = "Friend could not be added" 
            redirect_to books_path
        end
    end


    def destroy
        @friendship = Friendship.find_by(user_id: params[:user_id], friend_id: params[:id])
        @friendship.destroy!
        redirect_to books_path, notice: 'Friend removed successfully'
    end



end