class MoviesController < ApplicationController
  def index
    @movies = current_user.movies
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
    base_url = 'http://omdbapi.com/?s='
    search_term = params[:q]
    
    response = RestClient.get(base_url + search_term)
    data = JSON.parse(response.body)
    
    @movies = data["Search"]
    if @movies
      render :search
    else
      flash[:alert] = "Sorry, your search came back empty. Please try again."
      redirect_to root_path
    end 
  end
  
  def details
    @movie = Movie.new
    imdb_id = params[:imdb_id]
    url = "http://www.omdbapi.com/?i="
    end_point = url + imdb_id + '&plot=full'

    response = RestClient.get(end_point)
    @movie_info = JSON.parse(response.body)

    
  end 

  def show
  end

  def destroy
  end

  private
    def find_movie
      @movie = Movie.find(params[:id])
    end
    
    def movie_params
        params.require(:movie).permit(:title, :year, :plot, :imdb_id, :poster)
    end

end
