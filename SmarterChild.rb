require 'dotenv/load'
require 'discordrb'
require 'pry'
require 'pg'
require 'pp'

@bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_TOKEN"], client_id: ENV["DISCORD_CLIENT_ID"], prefix: '!'

@db = PG::Connection.open(:dbname => ENV['DB_NAME'], :user => ENV['DB_USER'])


# Future function that will check events more efficiently
# def check_events
#   results = @db.exec("
#     SELECT * FROM events 
#     WHERE reminder_time > LOCALTIMESTAMP(0);
#   ")
#   # binding.pry
# end

def check_db_for_events
  puts "YO" + " " + Time.now.to_s
  results = @db.exec("
    SELECT * FROM events 
    WHERE reminder_time = date_trunc('minute', CURRENT_TIMESTAMP(0));
  ")
  if !results.values.empty?
    results.values.each do |eventArr|
      user_results = @db.exec("
        SELECT discord_name, timezone, reminder_time AT TIME ZONE timezone
        FROM users u
        INNER JOIN user_events ue ON ue.user_id = u.user_id
        INNER JOIN events e ON e.event_id = ue.event_id
        WHERE ue.event_id = #{eventArr[0].to_i};
      ")
      @bot.find_user("#{user_results.values.flatten[0]}")[0].pm("**Reminder - #{eventArr[2]}**```#{eventArr[4]}```")
    end

    # timezoned_results = @db.exec("
    #   SELECT reminder_time AT TIME ZONE 'US/Eastern' FROM events                                   
    #   WHERE event_id = #{results.values.flatten[0].to_i};
    # ")
    # uri_time = results.values.flatten[3].split()[-2..-1].join(" ")
    # binding.pry

    
    # .send_embed("**Reminder**") do |embed|
    #   embed.colour = 0x4e06ca
    #   embed.add_field(name: "Title", value: "#{results.values.flatten[2]}")
    #   embed.add_field(name: "Message", value: "#{results.values.flatten[4]}")
    #   embed.add_field(name: "Time", value: "#{user_results.values.flatten[2]} (#{user_results.values.flatten[1]})")
    #   embed.description = "[Convert to your local time](https://duckduckgo.com/?#{URI.encode_www_form([["q", "#{uri_time}"]])}&ia=answer)"
    # end
  end
end


# Add "convert time" link to new event embed, and add user timezone query to get a select for utc time in user local time (Maybe uneccesary since user pm will have time)
def check_events
  check_db_for_events
  Thread.new do
    loop do 
      sleep 60
      check_db_for_events
    end
  end
end

check_events


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

# @db.exec("INSERT INTO events VALUES
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



#Rick Rolls whoever uses the word dank.
@bot.message(contains: 'dank') do |event|
  event.respond('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
end

#Useless mention function.
@bot.mention do |event|
  # binding.pry
  # Pry::ColorPrinter.pp(event.user.roles.inspect()) 
  event.user.pm("Hey #{event.user.name}, don't tell anyone we talked.")
end

#Reminder function

@bot.command(:reminder, usage: 'Remind me') do |event|

  if is_registered?(event)
    register_user(event)
    user_data = get_user_info(event)
    add_user_to_db(event, user_data)
  else
    create_user_event(event)
  end
  
end


#Basic math functions
@bot.command(:add, usage: 'Adds any amount of numbers together.') do |event, *integers|

  integers.map{|int| int.to_i}.inject{|sum,x| sum + x }
end

@bot.command(:multiply, description: 'Multiplies any amount of numbers together.') do |event, *integers|
  integers.map{|int| int.to_i}.inject{|product,x| product * x }
end

@bot.command(:subtract, description: 'Subtracts all the numbers given.') do |event, *integers|
  integers.map{|int| int.to_i}.inject{|difference,x| difference - x }
end

@bot.command(:divide, description: 'Divides all the numbers given.') do |event, *integers|
  integers.map{|int| int.to_f}.inject{|quotient,x| quotient / x }
end

@bot.command(:ball, description: 'Let the shake of an 8-ball determine your future.') do |event|
  options = [
        'It is certain', 'It is decidedly so', 'Without a doubt',
        'Yes, definitely', 'You may rely on it', 'You can count on it', 'As I see it, yes',
        'Most likely', 'Outlook good', 'Yes', 'Signs point to yes',
        'Reply hazy try again', 'Ask again later', 'Better not tell you now',
        'Cannot predict now', 'Concentrate and ask again', 'Don\'t count on it',
        'My reply is no', 'My sources say no', 'Outlook not so good',
        'Very doubtful', 'Chances aren\'t good' ]

          event.respond("🎱#{options[rand(0..21)]}🎱")
end

@bot.command(:dota2_a, description: "Show the last Dota 2 Game of Alienated.") do |event|
    hash = most_recent_dota_game(12540712)
    recent_game_match_id = hash["result"]["matches"][0]["match_id"]
    opendota_url = "https://www.opendota.com/matches/#{recent_game_match_id}"
    event.respond(opendota_url)
end

@bot.command(:dota2_g, description: "Show the last Dota 2 Game of Gingervitis.") do |event|
    hash = most_recent_dota_game(34933397)
    recent_game_match_id = hash["result"]["matches"][0]["match_id"]
    opendota_url = "https://www.opendota.com/matches/#{recent_game_match_id}"
    event.respond(opendota_url)
end

@bot.command(:dota2_t, description: "Show the last Dota 2 Game of Teebs.") do |event|
    hash = most_recent_dota_game(2148619)
    recent_game_match_id = hash["result"]["matches"][0]["match_id"]
    opendota_url = "https://www.opendota.com/matches/#{recent_game_match_id}"
    event.respond(opendota_url)
end

def make_web_request(url)
  all_recent_games = RestClient.get(url)
  JSON.parse(all_recent_games)
end

def most_recent_dota_game(account_id)
  header = "account_id=#{account_id}"
  valve_key = ENV['VALVE_KEY']
  url = "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?#{header}&key=#{valve_key}"
  all_recent_games_hash = make_web_request(url)
  all_recent_games_hash
end

#Reminder methods
def is_registered?(event)
  !event.user.roles.any? {|obj| obj.name == 'Touched By SmarterChild'} 
end

def register_user(event)
  registered_role = event.server.roles.find { |role| role.name == "Touched By SmarterChild" }
  event.user.add_role(registered_role)
end

def get_user_info(event)
  event.respond("Please enter your name (real or nickname): ")
  response = event.user.await!
  user_name = response.message.content
  event.respond("
  Please enter your timezone (1-8) ```1)US/Samoa 2)US/Hawaii 3)US/Alaska 4)US/Pacific 5)US/Mountain 6)US/Central 7)US/Eastern 8)Asia/Tokyo```
  ")
  timezone_hash = { 1 => "US/Samoa", 2 => "US/Hawaii", 3 => "US/Alaska", 4 => "US/Pacific", 5 => "US/Mountain", 6 => "US/Central", 7 => "US/Eastern", 8 => "Asia/Tokyo"}
  response = event.user.await!
  timezone_num = response.message.content.to_i
  user_hash = { :user_name => user_name, :discord_id => event.user.id, :discord_name => event.user.username, :timezone => timezone_hash[timezone_num]}
end

def add_user_to_db(event, user_data)
  @db.prepare('addusr', "
    INSERT INTO users (name, discord_id, discord_name, timezone)
    VALUES ($1::text, $2::bigint, $3::text, $4::text)
    ON CONFLICT (discord_id) 
    DO NOTHING
    RETURNING discord_id
  ;")
  results = @db.exec_prepared('addusr', [user_data[:user_name], user_data[:discord_id], user_data[:discord_name], user_data[:timezone]])
  @db.exec("DEALLOCATE addusr;")
  # If it executes result.values puts out the discord_id
  if !results.values.empty?
    event.respond "You've been registered!"
    results.clear
    create_user_event(event)
  else
    create_user_event(event)
  end
end

def create_user_event(event)
  binding.pry
  discord_id = event.user.id
  results = @db.exec("SELECT timezone, user_id from users WHERE discord_id = #{discord_id};")
  timezone = results.values.flatten[0]
  user_id = results.values.flatten[1].to_i
  automated_response = event.respond "Please enter the time & description of event (MM/DD/YY HH:MM AM/PM, Title, Message)"
  response = event.user.await!
  eventArr = response.message.content.split(/,\s*/)
  date = eventArr[0] + " " + timezone
  title = eventArr[1]
  message = eventArr[2]
  @db.prepare('addtime', "
    INSERT INTO events 
    VALUES (DEFAULT, DEFAULT, $1::text, $2::timestamptz, $3::text)
    RETURNING event_id, reminder_time - creation_time;
  ")
  results = @db.exec_prepared('addtime', [title, date, message])
  # binding.pry
  event_id = results.values.flatten[0].to_i
  time_till = results.values.flatten[1]
  @db.exec("DEALLOCATE addtime;")

  if !results.values.empty?
    @db.exec("
      INSERT INTO user_events 
      VALUES (#{user_id}, #{event_id});
    ")

    event.respond ">>> Reminder set for #{event.user.name} for #{time_till} from now."
    event.channel.delete_messages([event.message, automated_response, response.message])
    results.clear
  else
    event.respond "Event Registration Error"
  end
end



#Has to be at the end.
@bot.command(:exit, help_available: false) do |event|
  break unless event.user.id == ENV['ADMIN_DISCORD_ID']
  @bot.send_message(event.channel.id, 'SmarterChild is shutting down.')
  exit
end

@bot.run
