class FriendshipsController < ApplicationController


    def find
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