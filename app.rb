require 'bcrypt' # Man behöver bcrypt bibloteket för att kunna hasha. Det är bara en säkrare sätt att spara lösenord

# Man skriver den huvudsakliga sinatra klassen 
#Senare vid sinatra::Base tillåter helt enkelt att man kan använda applikationen. Tillåter gets, post osv.
class App < Sinatra::Base

    #Vi startar en session funktionalitet där man kan använda user_id tillexempel i programmer vilket är väldigt användbart.
    enable :sessions

    # Ansluter till SQLite databasen.
    #Vi gör det en gång och sparar allt i databas.
    def db 
        return @db if @db
        @db = SQLite3::Database.new("db/movie.sqlite")
        @db.results_as_hash = true 
        return @db
    end

    #Om vi kallar på roten ('/') går det till index sidan ('/movie')
    #Alltså först när man öppnar sidan går man direkt dit 
    get '/' do 
        redirect('/movie') #Den delen leder en till den sidan
    end

    #Detta används tillsammans med navigationen på sidan 
    #Om man är på ett annat sida kan man gå tillbaka till index sidan.
    get '/movie' do 
        erb(:"/movie/index")
    end

    #Visar upp alla våra filmer 
    #Tar upp allting sparade från table 'movies' i databasen
    get '/movies' do
        @movies = db.execute('SELECT * FROM movies') # Sparar allt data från i db i globala variabeln @movies
        erb:"/movie/movies" #Sedan går vi till sidan med alla filmer. erb är fil formaten tror jag.
    end

    #Detta används tillsammans med navigationen. 
    # Om man trycker på login går det till login sidan 
    get '/movie/login' do 
        erb(:"/movie/login")
    end

    # Detta används tillsammans med navigationen på sidan.
    # Om man inte har ett konto tar den dig till registrering sidan.
    get '/movie/register' do 
        erb(:'/movie/register')
    end

    # EN rot som ska visa all info om en specefik film 
    # Detta tar in ett id parameter för att kunna identifera vilken film det är.
    get '/movies/:id' do |id|
        @movie = db.execute('SELECT * FROM Movies WHERE id=?', id).first # Hämtar upp filmen med den specefika id

        if @movie.nil?
            halt 404, "Movie not found" # Om den filmen inte finns, till exempel om man skriver någonting i search baren kommer det upp att filmen inte finns.
        end

        erb(:"movie/show") # Tar en till sidan med specifik information om den filmen 
    end

    #För att redigera filmerna.  
    #Skapar också en lista över alla bilder och sparar dem i variabeln images som skickas till edit.erb
    get '/movies/:id/edit' do |id|
        @movie = db.execute('SELECT * FROM Movies WHERE id=?', id).first # Hämta upp allting om filmen från movies 
        @images = Dir.children("public/img").select {|file| file.match?(/\.(jpg|jpeg|png|gif)$/i) } # Lista alla bild filer i våran projekt i 'public/img'
       
        erb :"movie/edit" # Leda till redigerings sidan.
    end


    #Uppdatera detailjerna om en film 
    #Tar in data och uppdaterar enligt det i databasen
    post '/movies/:id/update' do |id|

        title = params[:movie_name] # Ta film namnet från datan.
        genre = params[:movie_genre]
        price = params[:movie_price]
        movie_description = params[:description]
        available = params[:available] == "on" ? 1 : 0
        image_filename = params[:image_filename]

        # Uppdatera allting om filmen i databasen med den nya informationen.
        db.execute("UPDATE movies SET title = ?, genre = ?, price = ?, movie_description = ?, available_for_rent = ?, image_filename = ? WHERE id = ?", [title, genre, price, movie_description, available, image_filename, id])

          redirect "/movies" #Gå tillbaka till film sidan efter uppdatering 
    end


    #För att radera en film 
    #Ta bort filmen med dess id 
    post '/movies/:id/delete' do |id|
        db.execute("DELETE FROM movies WHERE id = ?", [id]) #Radera filmen med id
        redirect "/movies" # Tillbaka till filmerna 
    end

    
    # Rot till sidan för att lägga till nya filmer
    get '/movie/new' do 
      @images = Dir.entries('./public/img').select { |f| f.match(/\.(jpg|jpeg|png|gif)$/i) && f != "." && f != ".." }
        erb(:"/movie/new")
    end


    #För att lägga till filmer. Typ samma som att redigera en film
    post '/movies/add' do 
        movie_name = params[:movie_name]
        movie_genre = params[:movie_genre]
        movie_price = params[:movie_price]
        movie_description = params[:movie_description]
        available = params[:available] == "on" ? 1 : 0
        image_filename = params[:image_filename]

        db.execute("INSERT INTO movies (title, genre, price, movie_description, available_for_rent, image_filename) VALUES (?, ?, ?, ?, ?, ?)", [movie_name, movie_genre, movie_price, movie_description, available, image_filename])

        redirect "/movies"
    end

    #Rot för att kunna lägga till nya användare. 
    #Användaren skriver in ett username och lösenord som vi hashar.
    post '/movie/register' do 
        username = params[:username]
        password = BCrypt::Password.create(params[:password])

        # Kollar om den valda usernamen redan finns i databasen 
        existing = db.execute("SELECT * FROM users WHERE username = ?", username).first
        if existing
          "Username already exists"
        else
          # Om inte så insertar vi den nya användaren till users tablen. Rollen blir alltid user då vi har endast en admin
          db.execute("INSERT INTO users (username, password, role) VALUES (?, ?, ?)", [username, password, "user"])
          redirect '/login'
        end
    end

    #Går till login efter redirect.
    get '/login' do 
        erb(:"/movie/login")
    end

    #För att logga in 
    post '/login' do 
        user = db.execute("SELECT * FROM users WHERE username = ?", params[:username]).first # Tar den användaren i datan med den specifika usernamen 

        # Vi veriferar att det är rätt lösenord och sen skapar en session för dem.
        if user && BCrypt::Password.new(user["password"]) == params[:password]
            session[:user_id] = user["id"] #Vi sparar anvöndaren id i sessionen 
            session[:role] = user['role'] # Vi sparar användarens role också 
            redirect '/'
        else 
            "Wrong username or password" # Om man har skrivit fel.
        end
    end 

    # För att logga ut. Bara starta om sessionen. Men vi har dock en grej 
    # Vi har sparat carten i en table, så när man kommer tillbaka är det fortfarande 
    # samma varor i carten.
    get '/logout' do 
        session.clear 
        redirect '/'
    end   

    helpers do
      def admin?
        session[:role] == "admin"
      end
    end

    #En shopping cart 
    #Lägger till filmer till shopping cart för användaren
    post '/cart/add/:id' do |id|
      user_id = session[:user_id] # Hämtar vem som är i sessionen beroende på användarens id 
      existing = db.execute("SELECT * FROM carts WHERE user_id = ? AND movie_id = ?", [user_id, id]).first #hämtar upp om den filmen redan finns i carten 

      #om det finns så lägger den inte till den men om den inte finns lägger vi till den i carte tablen.
      unless existing
        db.execute("INSERT INTO carts (user_id, movie_id) VALUES (?, ?)", [user_id, id])
      end
     
      redirect :'/movies'
    end


    #För att kunna se shopping carten 
    get '/cart' do 
      redirect '/login' unless session[:user_id] #Säkerställer bara så att man inte kan gå in i cart om man inte är inloggade eller en användare
      user_id = session[:user_id] # Tar användarens id 

      @cart_movies = db.execute(
        "SELECT movies.* FROM carts JOIN movies ON carts.movie_id = movies.id WHERE carts.user_id = ?", [user_id]
      )

      #Antal filmer och summa pengar
      @cart_count= @cart_movies.size
      @cart_total = @cart_movies.sum { |movie| movie['price'].to_f}

      erb :'cart/show'
    end

    #Ta bort enskilda filmers från carten
    post '/cart/remove/:movie_id' do |movie_id|
      # Tar bort filmen 
      db.execute("DELETE FROM carts WHERE user_id = ? AND movie_id = ?", [session[:user_id], movie_id])
      redirect '/cart'
    end

    #Att rensa carten
    #Rensa hela carten
    post '/clear_cart' do 
      #Ta bort allting från carts
      db.execute("DELETE FROM carts WHERE user_id = ?", [session[:user_id]])
      redirect'/cart'
    end

    helpers do
      def cart_count
        return 0 unless session[:user_id]
        db.execute("SELECT COUNT(*) AS count FROM carts WHERE user_id = ?", [session[:user_id]]).first['count']
      end 
    end

    # För att kunna hyra ut filmer 
    post '/rent' do 
      redirect '/login' unless session[:user_id]
      user_id = session[:user_id]

      # För över alla filmer i en variabel
      cart_items = db.execute('SELECT * FROM carts WHERE user_id = ?', [user_id])

      #Lägg till dem i uthyrda filmer
      cart_items.each do |item|
        db.execute('INSERT INTO rentals (user_id, movie_id, rental_date) VALUES (?, ?, ?)',[
          user_id,
          item['movie_id'],
          Time.now.to_s
        ])
      end

      #Ta bort allt från carts
      db.execute('DELETE FROM carts WHERE user_id = ?', [user_id])

      #Tacka användaren
      redirect '/movie/thanks'
    end

    get '/movie/thanks' do
      erb :'/movie/thanks'
    end

    get '/rentals' do 
      redirect '/login' unless session[:user_id]
      user_id = session[:user_id]

      @rentals = db.execute(
        'SELECT rentals.id AS rental_id, rentals.*, movies.* FROM rentals 
        JOIN movies ON rentals.movie_id = movies.id
        WHERE rentals.user_id = ?', [user_id]
      )
        

      erb :'rentals/index'
    end

    post '/clear_rentals' do 
      if session[:user_id]

        db.execute("DELETE FROM rentals WHERE user_id = ?", [session[:user_id]])
        redirect '/rentals'
      else
        redirect '/login'
      end
    end

    get '/rentals/:id' do |id|
      redirect '/login' unless session[:user_id]

      @rental = db.execute(
        'SELECT rentals.*, movies.* FROM rentals
        JOIN movies ON rentals.movie_id = movies.id
        WHERE rentals.id = ? AND rentals.user_id = ?', [id, session[:user_id]]
      ).first

        erb :'rentals/video'

    end

    get '/admin/dashboard' do 
      redirect '/login' unless session[:user_id]
      redirect '/' unless admin?

      @movies = db.execute('SELECT * FROM movies')
      @users = db.execute('SELECT * FROM users')
      @rentals = db.execute('SELECT rentals.*, movies.title, users.username, users.id as user_id FROM rentals
        JOIN movies ON rentals.movie_id = movies.id
        JOIN users ON rentals.user_id = users.id
        ORDER BY rental_date DESC')

      erb:'admin/dashboard'

    end

    #Kunna byta roller 
    post '/admin/users/:id/role' do |id|
      redirect '/login' unless session[:user_id]
      redirect '/' unless admin?

      new_role = params[:role]
      db.execute("UPDATE users SET role = ? WHERE id = ?", [new_role, id])
      redirect '/admin/dashboard'
    end

    #För att kunna ta bort användare
    post '/admin/users/:id/delete' do |id|
      redirect '/login' unless session[:user_id]
      redirect '/' unless admin?

      db.execute("DELETE FROM users WHERE id =?", [id])
      redirect '/admin/dashboard'
    end

    #Se vad man har hyrt
    get '/admin/users/:id/rentals' do |id|
      redirect '/login' unless session[:user_id]
      redirect '/' unless admin?

      @user = db.execute("SELECT * FROM users WHERE id = ?", [id]).first
      @rentals = db.execute(
        'SELECT rentals.*, movies.title, movies.image_filename FROM rentals 
        JOIN movies ON rentals.movie_id = movies.id
        WHERE rentals.user_id = ?', [id]
      )

      erb:'admin/rentals'
    end


end