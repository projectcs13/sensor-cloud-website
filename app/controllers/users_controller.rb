class UsersController < ApplicationController
    before_action :signed_in_user,   only: [:index, :edit, :update, :destroy, :profile, :following]
    before_action :correct_user,     only: [:edit, :update]
    before_action :admin_user,       only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

    def edit
        @user.private = if @user.private == true then "1" else "0" end
    end

    def show
        @user = User.find_by_username(params[:id])
        if @user == nil
            redirect_to notfound_path
        else
            res = Api.get("/users/#{@user.username}/streams")
            @streams = res["body"]["streams"]
            @nb_streams = @streams.length
            res2 = Api.get("/users/#{@user.username}")
            @notifications = res2["body"]["notifications"]
            sorted = @notifications.sort_by { |hsh| hsh[:timestamp] }.reverse
            @notifications = sorted
        end
    end

    def following
        @title = "Following"
        @user = User.find_by_username(params[:id])
        cid = current_user.username
        res = Api.get("/users/#{cid}")
        @subscriptions = res["body"]["subscriptions"]
        @stream_ids = @subscriptions.map { |e| e["stream_id"] }
        @streams = @stream_ids.map do |s|
            res = Api.get("/streams/" + s)
            res["body"]
        end
    end

    def auth_google
        logger.debug "AUTH-GOOGLE"

        if params[:error]
            logger.debug "ERROR"
            case params[:error]
            when :user_signed_out
                flash.now[:danger] = "User is signed-out. Please sign in again."
            when :access_denied
                flash.now[:danger] = "User denied the access. Not possible to sign in."
            when :immediate_failed
                flash.now[:danger] = "Immediate failed. Could not automatically log in the user."
            else
                flash.now[:danger] = "Unknown error in user authentication."
            end
            redirect_to signin_url
            # if params[:error] == "immediate_failed" and params[:error_subtype] == "access_denied"
            #     flash[:warning] = "Please sign in"
            #     redirect_to signin_url
            # end
        else
            # res = send_openidc_request params

            # Create new user based on the response
            logger.debug "RES:"
            logger.debug res

            redirect_to "/streams"
        end

        # @user = User.new(auth_params)

        # logger.debug @user.attributes

        # if @user.save
        #     redirect_to '/streams'
        # else
        #     signed_in_user
        # end
    end

    def send_openidc_request(params)
        Api.post("/auth/openid", params)
    end

    def new
        @user = User.new
        attributes = ["username", "firstname", "lastname", "description", "password", "email", "private"]
        attributes.each do |attr|
        @user.send("#{attr}=", nil)
    end
  end

    def create
        @user = User.new(user_params)
        params[:user][:private] = !(params[:user][:private].to_i).zero?
        if @user.save
            sign_in @user
            res = Api.post("/users",
                params[:user].slice(:username, :email, :password, :firstname, :lastname, :description, :private)
            )
            flash[:success] = "Welcome to the Sample App!"
            redirect_to @user
        else
            render 'new'
        end
    end

    def update
        params[:user][:private] = !(params[:user][:private].to_i).zero?
        if @user.update_attributes(user_params)
            flash[:success] = "Account updated"
            @user.save
            res = Api.put(
                "/users/#{@user.username}",
                params[:user].slice(:email, :password, :firstname, :lastname, :description, :private)
            )
            redirect_to @user
        else
            render 'edit'
        end
    end

    def destroy
        @user = User.find_by_username(params[:id])
        @user.destroy

        flash[:success] = "User destroyed."
        redirect_to users_url
    end

    private
        def user_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation, :firstname, :lastname, :description, :private)
        end

        def auth_params
            params.permit(:access_token, :id_token)
        end

        # Before filters
        def signed_in_user
            unless signed_in?
                store_location
                flash[:warning] = "Please sign in"
                redirect_to signin_url
            end
        end

        def correct_user
            @user = User.find_by_username(params[:id])
            redirect_to(root_url) unless current_user?(@user)
        end

        def admin_user
            redirect_to(root_url) unless current_user.admin?
        end
end
