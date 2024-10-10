# producer.rb
require 'bunny'
require 'json'

# Connect to RabbitMQ
connection = Bunny.new(hostname: 'rabbitmq', username: 'mikelopster', password: 'password')
connection.start

channel = connection.create_channel
queue = channel.queue('movies')

# Movie data to be pushed to RabbitMQ
movies = [
  { title: 'Oppenheimer', director: 'Christopher Nolan', year: 2010 },
  { title: 'The Batman', director: 'Lana Wachowski, Lilly Wachowski', year: 1999 },
  { title: 'Interstellar', director: 'Christopher Nolan', year: 2014 }
]

# Publish movie data to RabbitMQ
movies.each do |movie|
  queue.publish(movie.to_json)
  puts "Published movie: #{movie[:title]}"
end

# Close the connection
connection.close
