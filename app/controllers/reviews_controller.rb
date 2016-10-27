class ReviewsController < ApplicationController
      before_action :find_review, only: [:edit, :update, :destroy]

  def create
  	@movie = Movie.find(params[:movie_id])
  	@review = @movie.reviews.build(review_params)
  	@review.user = current_user
  	if @movie.save
  		flash[:notice] = "Review added successfully."
  		redirect_to @movie
  	else
  		flash[:alert] = "Review could not be added, please try again."
  		redirect_to @movie
  	end
  end

  def edit
  	if @review.user != current_user
  	    not_correct_user
  	end
  end

  def update
  	if @review.user == current_user
  		if @review.update(review_params)
  			flash[:notice] = "Review updated successfully."
  			redirect_to @review.movie
  		else
  			flash[:alert] = "Unable to update review."
  			render :edit
  		end
  	else
  	    not_correct_user
  	end

  end

  def destroy
  	@movie = @review.movie
  	if @review.user == current_user
  		@review.destroy
  		flash[:alert] = "Review deleted successfully."
  		redirect_to @movie
  	else
  	    not_correct_user
  	end
  end

  private
  	def find_review
  		@review = Review.find(params[:id])
  	end

    def not_correct_user
        flash[:alert] = "You don't have permission to edit this review."
  		sign_out current_user
  		redirect_to root_path
  	end 
        

  	def review_params
  		params.require(:review).permit(:body)
  	end
end
