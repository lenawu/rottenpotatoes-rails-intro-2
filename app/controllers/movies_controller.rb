class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
 
    #handles if a sort is needed and keep track of session
    sort_req = session[:sort] || params[:sort] 
    case sort_req
    when 'title_sort'
      sort_type = {:title_sort => :asc}
      @title_header = 'hilite' 
    when 'release_date_sort'
      sort_type = {:release_date_sort => :asc}
      @date_header = 'hilite' 
    end
    #get possible ratings and list of ratings selected
    @all_ratings = Movie.all_ratings
    @ratings_list = session[:ratings] || params[:ratings] || {} 
    #handle case where ratings are empty
    if @ratings_list == {}
      @ratings_list = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
    #otherwise, see what needs to be kept and changed with sort and ratings
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @ratings_list
      redirect_to :sort => sort, :ratings => @ratings_list and return
    end
    @movies = Movie.where(rating: @ratings_list.keys).order(sort_type)
  end 

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
