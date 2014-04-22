require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
  erb :index  
end

get '/movies' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)          
  @movies = c.exec_params("SELECT * FROM movies WHERE title = $1;", [params["title"]])            
  c.close 
  erb :movies         
end

get '/movie/:id' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)          
  @movies = c.exec_params("SELECT * FROM movies WHERE id = $1;", [params["id"]])
  erb :details  ### TODO MAKE DETAILS PAGE         
end

get '/movie/:id' do
  # details of one movie      list of actors in phase 4 as well...
end

get '/movies/new' do
  erb :new
end

post '/movies' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)          # sets postgres connection
  c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2)",       
                  [params["title"], params["year"]])          # sql to database
  c.close             # close database connection
  redirect '/'
end

# get '/results' do
#   res=Typhoeus.get("www.omdbapi.com/", :params => { :s => params["movie"] }) 
#   json_results = JSON.parse(res.body) 
#     @movies = json_results["Search"]   # .each this on erb page 
#     @movies = @movies.sort_by {|x| x["Year"]}    #sorts by year
#     @movies = @movies.reverse                    #most recent displayed first
#     puts @movies
#   erb :results
# end

def dbname
  "movie_party"
end

def create_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title varchar(255),
    year varchar(255),
    plot text,
    genre varchar(255)
  );
  }
  connection.close
end

def drop_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec "DROP TABLE movies;"
  connection.close
end

def seed_movies_table
  movies = [["Glitter", "2001"],
              ["Titanic", "1997"],
              ["Sharknado", "2013"],
              ["Jaws", "1975"]
             ]
 
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  movies.each do |p|
    c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2);", p)
  end
  c.close
end

