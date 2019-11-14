require 'dotenv/load'
require 'discordrb'
require 'pry'
require 'pg'
require 'pp'

module Bot
  # Load non-Discordrb modules
  Dir['src/modules/*.rb'].each { |mod| load mod }

  BOT = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_TOKEN"], client_id: ENV["DISCORD_CLIENT_ID"], prefix: '!'

  DB = PG::Connection.open(:dbname => ENV['DB_NAME'], :user => ENV['DB_USER'])

  # Load all the modules in the events and commands directories
  def self.load_modules(klass, path)
    new_module = Module.new
    const_set(klass.to_sym, new_module)
    Dir["src/modules/#{path}/*.rb"].each { |file| load file }
    new_module.constants.each do |mod|
      BOT.include! new_module.const_get(mod)
    end
  end

  load_modules(:DiscordEvents, 'events')
  load_modules(:DiscordCommands, 'commands')

  # binding.pry
  # Future function that will check events more efficiently
  # def check_events
  #   results = DB.exec("
  #     SELECT * FROM events 
  #     WHERE reminder_time > LOCALTIMESTAMP(0);
  #   ")
  #   # binding.pry
  # end

  # Add "convert time" link to new event embed, and add user timezone query to get a select for utc time in user local time (Maybe uneccesary since user pm will have time)

  # Timezones (no tz)
  # From one user's eastern timezone to another user's pacific
  # SELECT reminder_time AT TIME ZONE 'US/Pacific' AT TIME ZONE 'US/Eastern' FROM events WHERE event_id=1;
  # From utc to user's default timezone
  # SELECT creation_time AT TIME ZONE 'US/Eastern' FROM events WHERE event_id=1;
  # The time it was set
  # SELECT reminder_time AT TIME ZONE 'UTC' FROM events WHERE event_id=1;


  # db.exec("INSERT INTO users VALUES
  # (DEFAULT, 'test', 105, 'adawg');")

  # db.exec("
  #   INSERT INTO users 
  #   VALUES (DEFAULT, 'smith', 111, 'falcon');
  #   ")

  # db.exec("
  #   INSERT INTO users (user_id, name, discord_id, discord_name)
  #   VALUES (DEFAULT, 'smith', 111, 'falcon')
  #   ON CONFLICT (discord_id) 
  #   DO NOTHING
  #   RETURNING discord_id
  #   ;")

  # DB.exec("INSERT INTO events VALUES
  # (DEFAULT, DEFAULT, 'Making spaghetti.', '10/05/2019 10:00+05', 'Have to make the sausage.');")

  # db.exec("INSERT INTO events VALUES
  # (DEFAULT, DEFAULT, DEFAULT, 'Strategy Time', '2019-10-01', '12:00:00', 'Decide how to conquer the world.');")

  # db.exec("INSERT INTO events VALUES
  # (DEFAULT, DEFAULT, DEFAULT, 'Smith Time', '2019-10-01', '13:00:00', 'Lonely event.');")

  # db.exec("INSERT INTO user_events VALUES
  # (1, 1);")

  # db.exec("INSERT INTO user_events VALUES
  # (1, 2);")

  # db.exec("INSERT INTO user_events VALUES
  # (2, 3);")

  # db.exec("
  #   SELECT event_title
  #   FROM events e
  #   INNER JOIN user_events ue ON ue.event_id = e.event_id
  #   INNER JOIN users u ON u.user_id = ue.user_id
  #   WHERE ue.user_id = 1
  # ;")

  # db.exec("
  #   SELECT name
  #   FROM users u
  #   INNER JOIN user_events ue ON ue.user_id = u.user_id
  #   INNER JOIN events e ON e.event_id = ue.event_id
  #   WHERE ue.event_id = 1
  # ;")

  # db.exec("
  # SELECT discord_id, timezone, reminder_time AT TIME ZONE 'US/Central'
  # FROM users u
  # INNER JOIN user_events ue ON ue.user_id = u.user_id
  # INNER JOIN events e ON e.event_id = ue.event_id
  # WHERE ue.event_id = 35;
  # ")


  # begin

  #   puts db.server_version

  # rescue PG::Error => e

  #   puts e.message 
    
  # ensure

  #   db.close if db
    
  # end

  #Has to be at the end.
  BOT.command(%i[exit quit], help_available: false) do |event|
    break unless event.user.id == ENV['ADMIN_DISCORD_ID'].to_i
    BOT.send_message(event.channel.id, 'SmarterChild is shutting down.')
    exit
  end

  BOT.run

end