class StatisticsController < ApplicationController
	def index
		@statistics = Statistic.all
	end

	def new
		@statistic = Statistic.new
	end

	def show
		@statistic = Statistic.find(params[:id])
		#binding.pry
		""
	end

	def create
		@statistic = Statistic.new(statistic_params)
		access_token = get_acces_token(APP_ID, APP_SECRET)
		page = get_page(statistic_params["page_id"], access_token)
		@statistic.name = page.name
		@statistic.picture = page.picture.url

		count = get_like_and_comment_count(page)
		@statistic.save!

		count.each do |uid,v|
			user = FbGraph2::User.new(uid).authenticate(access_token).fetch

			@statistic.likes.build(uid: uid, name: v[:name], like_count: v[:like_count],
			 comment_count: v[:comment_count], picture: user.picture.url).save!
		end
		#binding.pry
		""
		redirect_to statistic_path(@statistic )
	end

	private
	def statistic_params
		params.require(:statistic).permit(:page_id)
	end

	def get_acces_token(app_id, app_secret)
		auth = FbGraph2::Auth.new(app_id, app_secret)
		auth.access_token!
	end

	def get_page(page_id, access_token)
		FbGraph2::Page.new(page_id).authenticate(access_token)
	end

	def get_like_and_comment_count(page)
		feeds = page.feed(limit: 30)
		count = {}
		feeds.each do |feed|
			feed.edge(:comments).each do |comment| 
				id = comment["from"]["id"]
				name = comment["from"]["name"]
				puts "comment: #{id}: #{name}"
				if count[id]
					count[id][:comment_count] += 1
				else
					count[id] = Hash.new 0
					count[id][:name] = name
					count[id][:comment_count] = 1
				end
			end
			feed.edge(:likes).each do |like| 
				id = like["id"]
				name = like["name"]
				puts "like: #{id}: #{name}"
				if count[id]
					count[id][:like_count] += 1
				else
					count[id] = Hash.new 0
					count[id][:name] = name
					count[id][:like_count] = 1
				end
			end
		end
		count
	end
end
