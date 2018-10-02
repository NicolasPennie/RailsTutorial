class MicropostsController < ApplicationController
	before_action :logged_in_user
	
	def create
		@micropost = current_user.microposts.build(micropost_params)
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_url
		else
			@feed_items = current_user.feed.paginate(page: params[:page], per_page: 10)
			render 'static_pages/home'
		end
	end
	
	def destroy
	end
	
	private
	
		def micropost_params
			params.require(:micropost).permit(:content)
		end
end
