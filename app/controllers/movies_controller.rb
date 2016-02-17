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
    reset_session
    #handles if a sort is needed and keep track of session
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      sorting = {:title => :asc}
      @title_header = 'hilite'
    when 'release_date'
      sorting = {:release_date => :asc}
      @date_header = 'hilite'
    end

    #get possible ratings and list of ratings selected
    @all_ratings = Movie.all_ratings
    @ratings_list = params[:ratings] || session[:ratings] || {}
    #handle case where ratings are empty
    if @ratings_list == {}
	for rating in @all_ratings
		@ratings_list[:rating] = rating	
	end   
    end
    #otherwise, see what needs to be kept and changed with sort and ratings
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @ratings_list
      redirect_to :sort => sort, :ratings => @ratings_list
      return
    end
    @movies = Movie.where(rating: @ratings_list.keys).order(sorting)
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
