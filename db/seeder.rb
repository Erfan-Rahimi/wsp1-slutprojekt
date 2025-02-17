
require 'sqlite3'

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
  end

  def self.create_tables
    db.execute('CREATE TABLE movies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                genre TEXT,
                price REAL NOT NULL,
                available_for_rent BOOLEAN NOT NULL DEFAULT 1)')

    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL)')

    db.execute('CREATE TABLE rentals (
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      user_id INTEGER NOT NULL,
      movie_id INTEGER NOT NULL,
      rental_date TEXT NOT NULL,
      return_date TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(movie_id) REFERENCES movies(id))')
  end

  def self.populate_tables
    db.execute('INSERT INTO movies (title, genre, price, available_for_rent) VALUES (?,?,?,?)',
    ["Inception", "Sci-Fi", 3.99, 1])

    db.execute('INSERT INTO movies (title, genre, price, available_for_rent) VALUES (?,?,?,?)',
      ["The Dark Knight", "Action", 2.99, 1])

    db.execute('INSERT INTO movies (title, genre, price, available_for_rent) VALUES (?,?,?,?)',
      ["Interstellar", "Sci-Fi", 4.99, 1])

    password_hashed = BCrypt::Password.create("123")
    p "Storing hashed version of password to db. Clear text never saved. #{password_hashed}"
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["ola", password_hashed])
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