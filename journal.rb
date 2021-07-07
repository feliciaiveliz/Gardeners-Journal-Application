require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:plants] ||= []
end

# Return an error message if the name is invalid. Return nil if name is valid.
def plant_name_error(name)
  if !(1..100).cover?(name.size)
    "The plant name must be between 1 and 100 characters."
  end
end

get "/" do
  redirect "/plants"
end

# View all plant entries (home page)
get "/plants" do
  @plants = session[:plants]
  erb :plants, layout: :layout
end

# View future plant entries
get "/plants/future-plants" do
  @plants = session[:plants]
  erb :future_plants, layout: :layout
end

# View new plant form
get "/plants/new" do
  erb :new_plant, layout: :layout
end

# Add a new plant
post "/plants" do
  @plant_list = session[:plants]
  plant_name = params[:plant_name]
  plant_type = params[:plant_type]
  date_planted = params[:date_planted]
  sunlight = params[:sunlight]
  height = params[:height]
  harvest = params[:harvest]
  notes = params[:notes]
  choice = params[:choice]

  error = plant_name_error(plant_name)
  if error
    session[:error] = error
    erb :new_plant, layout: :layout
  end

  @plant_list << {
    name: plant_name,
    date_planted: date_planted,
    plant_type: plant_type,
    sunlight: sunlight,
    height: height,
    harvest: harvest,
    notes: notes,
    choice: choice
  }

  if params[:choice] == "future"
    session[:success] = "#{plant_name} has been added to your future garden!"
    redirect "/plants/future-plants"
  else
    session[:success] = "#{plant_name} has been added to your garden!"
    redirect "/plants"
  end
end

# View a single plant
get "/plants/:id" do
  id = params[:id].to_i
  @plant_list = session[:plants][id]
  erb :plant, layout: :layout
end

# Edit an existing plant
get "/plants/:id/edit" do
  id = params[:id].to_i
  @plant_list = session[:plants][id]
  erb :edit_plant, layout: :layout
end

# Update an existing plant entry
post "/plants/:id" do
  plant_name = params[:plant_name]
  date_planted = params[:date_planted]
  plant_type = params[:plant_type]
  sunlight = params[:sunlight]
  height = params[:height]
  harvest = params[:harvest]
  notes = params[:notes]
  choice = params[:choice]

  id = params[:id].to_i
  @plant_list = session[:plants][id]
  
  error = plant_name_error(plant_name)
  if error
    session[:error] = error
    erb :edit_plant, layout: :layout
  end

  @plant_list = {
    name: plant_name,
    date_planted: date_planted,
    plant_type: plant_type,
    sunlight: sunlight,
    height: height,
    harvest: harvest,
    notes: notes,
    choice: choice
  }

  if params[:choice] == "current"
    session[:success] = "#{plant_name} has been moved to your current garden!"
    redirect "/plants"
  else
    session[:success] = "#{plant_name} has been updated."
    redirect "/plants/#{id}"
  end
end

# Delete a plant
post "/plants/:id/delete" do
  id = params[:id].to_i
  plant = session[:plants].delete_at(id)
  session[:error] = "#{plant[:name]} has been deleted."
  redirect "/plants"
end
