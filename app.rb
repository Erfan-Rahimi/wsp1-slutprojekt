require 'sinatra/base'
require 'sqlite3'
require 'bcrypt'
require 'securerandom'


class App < Sinatra::Base
    enable :sessions
    set :session_secret, SecureRandom.hex(64)

    def db 
        return @db if @db
        @db = SQLite3::Database.new('db/movie.sqlite')
        @db.results_as_hash = true 
        return @db
    end 

    get '/' do
        erb :index
    end

    # === Användarhantering ===

    #Login-sida 
    get '/login' do 
        erb :login
    end

    # Hanterar inloggningen 
    post '/login' do 
        username = params[:username]
        password = params[:password]

        user = db.execute("SELECT * FROM users WHERE username =?", [username]).first

        if user && BCrypt::Password.new(user["password"]) == password
            session[:user_id] = user["id"]
            session[:role] = user["role"] # Sparar om användaren som loggar in är en vanligt användare eller en admin
            redirect '/movies'
        else
            redirect '/unauthorized'
        end
    end 

    # För att kunna registrera en ny användare 

    get'/register' do 
        erb :register 
    end 

    post '/register' do
        username = params[:username]
        password = BCrypt::Password.create(params[:password])
        role = params[:role] || "user"

        db.execute("INSERT INTO users (username, password, role) VALUES (?, ?, ?)", [username, password, role])
        redirect '/login'
    end

    # För att sen kunna logga ut 

    get '/logout' do 
        session.clear
        redirect '/'
    end

    #Unauthorized-sida 
    get '/unauthorized' do 
        erb : unauthorized
    end

    # Listan över alla filmer 

    get '/movies' do 
        @movies = db.execute("SELECT * FROM movies WHERE available_for_rent = 1")
        erb :movies
    end

    # Dessa är alla adminfunktioner för alla filmer 

    #Detta är en adminpanel som endast admin borde kunna få se 
    get '/admin' do 
        redirect '/unathorized' unless session[:role] == "admin"
        @movies = db.execute("SELECT * FROM movies")
        erb :admin
    end

    # Kunna lägga till en ny film 

    get '/movies/new' do 
        redirect '/unauthorized' unless session[:role] == "admin"
        erb :new_movie
    end

    post '/movies' do 
        redirect '/unauthorized' unless session[:role] == "admin"

        title = params[:title]
        genre = params[:genre]
        price = params[:price].to_f
        db.execute("INSERT INTO movies (title, genre, price, available_for_rent) VALUES (?,?,?,1)", [title, genre, price])

        redirect '/admin'
    end

    #För att kunna redigera ett film 

    get '/movies/:id/edit' do 
        redirect '/unauthorized' unless session[:role] == "admin"

        @movie = db.execute("SELECT * FROM movies WHERE id =?", [params[:id]]).first
        erb :edit_movie
    end

    #För att kunna uppdatera 

    post '/movies/:id/update' do 
        redirect '/unauthorized' unless session[:role] == "admin"

        title = params[:title]
        genre = params[:genre]
        price = params[:price].to_f
        id = params[:id]

        db.execute("UPDATE movies SET title = ?, genre = ?, price = ? WHERE id= ?", [title, genre, price, id])
        redirect '/admin'
    end

    # För att kunna ta bort en film 
    post '/movies/:id/delte' do 
        redirect '/unauthorized' unless session[:role] == "admin"

        db.execute("DELETE FROM movies WHERE id = ?", [params[:id]])
        redirect '/admin'
    end

    # Användaren ska kunna hyra ut ett film 

    post '/rent/:movies_id' do 
        redirect '/login' unless session[:user_id]

        movie_id = params[:movie_id]
        user_id = session[:user_id]
        rental_date = Time.now.strftime("%Y-%m-%d")

        db.execute("INSERT INTO rentals (user_id, movie_id, rental_date) VALUES (?, ?, ?)", [user_id, movie_id, rental_date])
        db.execute("UPDATE movies SET available_for_rent = 0 WEHRE id = ?", [movie_id])

        redirect '/movies'
    end

    # En lista av alla uthyrda folmer för inloggade användare

    get '/rentals' do 
        redirect '/login' unless session[:user_id]

        user_id = session[:user_id]
        @rentals = db.execute("SELECT movies.title, rentals.rental_date FROM rentals 
            JOIN movies ON rentals.movie_id = movies.id WHERE rentals.user_id = ?", [user_id])
        
        erb :rentals
    
    end

    #Att lämna tillbaka en film 

    post '/return/:movie_id' do 
        redirect '/login' unless session[:user_id]

        movie_id = params[:movie_id]
        user_id = session[:user_id]

        db.execute("UPDATE rentals SET return_date = ? WHERE movie_id = ? AND user_id = ?", [Time.now.strftime("%Y-%m-%d"), movie_id, user_id])
        db.execute("UPDATE movies SET available_for_rent = 1 WHERE id = ?", [movie_id])

        redirect '/rentals'
    end

end