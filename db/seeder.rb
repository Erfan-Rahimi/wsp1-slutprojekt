#Nödvändiga biblotek
require 'sqlite3' # Tillåter oss att använda SQLite databas och använda SQL kommand i ruby språket
require 'bcrypt' # Bibloteket för att kunna hasha lösenord 

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS movies')
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS rentals')
    db.execute('DROP TABLE IF EXISTS carts')
  end

  def self.create_tables

    db.execute('CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT "user"
      )')

    db.execute('CREATE TABLE movies (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      genre TEXT,
      price REAL NOT NULL,
      available_for_rent BOOLEAN NOT NULL DEFAULT 1,
      image_filename TEXT NOT NULL,
      movie_description TEXT NOT NULL)')

    db.execute('CREATE TABLE rentals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      movie_id INTEGER NOT NULL,
      rental_date TEXT NOT NULL,
      return_date TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(movie_id) REFERENCES movies(id))')

      db.execute('CREATE TABLE carts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id  INTEGER NOT NULL,
        movie_id INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(movie_id) REFERENCES movies(id))')
  end

  def self.populate_tables

    #Skapa en admin
    admin_password = BCrypt::Password.create("Erfan")
    db.execute('INSERT INTO users (username, password, role) VALUES (?, ?, ?)', ["admin", admin_password, "admin"])

    #Skapa en vanlig användare
    user_password =  BCrypt::Password.create("Lotus")
    db.execute('INSERT INTO users (username, password, role) VALUES (?, ?, ?)', ["Lotus Gyllensvaan", user_password, "user"])

    # Insert some movies
    db.execute('INSERT INTO movies (title, genre, price, available_for_rent, image_filename, movie_description) VALUES (?,?,?,?,?,?)',
    ["Inception", "Sci-Fi", 3.99, 1, "action.jpg", "Shishio has set sail in his ironclad ship to bring down the Meiji government and return Japan to chaos, carrying Kaoru with him. In order to stop him in time, Kenshin trains with his old mas..."])

    db.execute('INSERT INTO movies (title, genre, price, available_for_rent, image_filename, movie_description) VALUES (?,?,?,?,?,?)',
    ["The Dark Knight", "Action", 2.99, 1, "animation.jpg", "When an unconfident young woman is cursed with an old body by a spiteful witch, her only chance of breaking the spell lies with a self-indulgent yet insecure young wizard and his companions ..."])

    db.execute('INSERT INTO movies (title, genre, price, available_for_rent, image_filename, movie_description) VALUES (?,?,?,?,?,?)',
    ["Mother", "Sci-Fi", 4.99, 1, "crime.jpg", "A mother desperately searches for the killer who framed her son for a girl's horrific murder."])
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/movie.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!
