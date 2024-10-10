# consumer.rb
require 'bunny'
require 'pg'
require 'json'

# Connect to RabbitMQ
connection = Bunny.new(hostname: 'rabbitmq', username: 'mikelopster', password: 'password')
connection.start

channel = connection.create_channel
queue = channel.queue('movies')

# Connect to PostgreSQL
db_connection = PG.connect(
  dbname: 'orders',
  user: 'root',
  password: 'rootpassword',
  host: 'postgres',
  port: 5432
)

# Create movies table if it doesn't exist
db_connection.exec(<<-SQL
  CREATE TABLE IF NOT EXISTS movies (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    director VARCHAR(255),
    year INT
  );
SQL
)

# Consume messages from RabbitMQ and insert into PostgreSQL
def consume_and_store(queue, db_connection)
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    movie = JSON.parse(body)
    db_connection.exec_params(
      'INSERT INTO movies (title, director, year) VALUES ($1, $2, $3)',
      [movie['title'], movie['director'], movie['year']]
    )
    puts "Inserted movie: #{movie['title']}"
  end
end

consume_and_store(queue, db_connection)

# Close the connections
connection.close
db_connection.close