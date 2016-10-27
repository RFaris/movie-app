class MoviesController < ApplicationController
  before_action :find_movie, only: [:show, :destroy]
  
  def index
    if params[:search]
      @movies = current_user.movies.where("title ILIKE?", "%#{params[:search]}%")
    else
      @movies = current_user.movies
    end
  end

  def create
    @movies = Movie.all
    if @movies.map(&:imdb_id).include?(movie_params[:imdb_id])
      @movie = Movie.find_by(imdb_id: movie_params[:imdb_id])
      @movie.users << current_user
      flash[:notice] = "#{@movie.title} successfully favorited."
      redirect_to @movie
    else
      @movie = current_user.movies.build(movie_params)
      if current_user.save
        flash[:notice] = "#{@movie.title} successfully favorited."
        redirect_to @movie
      else
        flash[:alert] = "Unable to favorite movie."
        redirect_to root_path
      end
    end
  end
  
  def search
  	base_url = 'http://www.omdbapi.com/?s='
  	search_term = params[:q]
  	end_point = base_url + search_term

  	response = RestClient.get(end_point)
  	data = JSON.parse(response.body)

  	@movies = data["Search"]
  	if @movies
  		render :search
  	else
  		flash[:alert] = "Sorry, your search came back empty, please try again."
			redirect_to root_path
		end
  end
  
  def details
    @movie = Movie.new
  	imdb_id = params[:imdb_id]
  	base_url = "http://www.omdbapi.com/?i="
  	end_point = base_url + imdb_id + '&plot=full'

  	response = RestClient.get(end_point)

  	@movie_info = JSON.parse(response.body)
  end

  def show
    # find_movie being run before_action
    @review = Review.new
  end

  def destroy
    # find_movie being run before_action
    current_user.movies.delete(@movie)
    flash[:alert] = "Movie successfully deleted!"
    redirect_to movies_path
  end

  private
    def find_movie
      @movie = Movie.find(params[:id])
    end

    def movie_params
        params.require(:movie).permit(:title, :year, :plot, :imdb_id, :poster)
    end
end