def check_db_for_events
    puts "YO" + " " + Time.now.to_s
    results = Bot::DB.exec("
        SELECT * FROM events 
        WHERE reminder_time = date_trunc('minute', CURRENT_TIMESTAMP(0));
    ")
    if !results.values.empty?
        results.values.each do |eventArr|
            if eventArr[4].to_i === 2
                user_results = Bot::DB.exec("
                    SELECT discord_name, timezone, reminder_time AT TIME ZONE timezone
                    FROM users u
                    INNER JOIN user_events ue ON ue.user_id = u.user_id
                    INNER JOIN events e ON e.event_id = ue.event_id
                    WHERE ue.event_id = #{eventArr[0].to_i};
                ")
                Bot::BOT.find_user("#{user_results.values.flatten[0]}")[0].pm("**Reminder - #{eventArr[2]}**```#{eventArr[5]}```")
            elsif eventArr[4].to_i === 1
                uri_time = eventArr[3].split()[-2..-1].join(" ")
                date = eventArr[3].split()[0]
                Bot::BOT.find_channel("test")[0].send_embed("**Event**") do |embed|
                    embed.colour = 0x4e06ca
                    embed.add_field(name: "Title", value: "#{eventArr[2]}")
                    embed.add_field(name: "Message", value: "#{eventArr[5]}")
                    embed.add_field(name: "Date", value: "#{date}")
                    embed.add_field(name: "Time", value: "#{uri_time}")
                    embed.description = "[Convert to your local time](https://duckduckgo.com/?#{URI.encode_www_form([["q", "#{uri_time}"]])}&ia=answer)"
                end
            end
        end
    end
end

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
    Bot::DB.prepare('addusr', "
        INSERT INTO users (name, discord_id, discord_name, timezone)
        VALUES ($1::text, $2::bigint, $3::text, $4::text)
        ON CONFLICT (discord_id) 
        DO NOTHING
        RETURNING discord_id;
    ")
    results = Bot::DB.exec_prepared('addusr', [user_data[:user_name], user_data[:discord_id], user_data[:discord_name], user_data[:timezone]])
    Bot::DB.exec("DEALLOCATE addusr;")
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
    discord_id = event.user.id
    if event.command.name === :event
        event_type = 1
        results = Bot::DB.exec("SELECT timezone, user_id from users WHERE discord_id = #{discord_id};")
        timezone = results.values.flatten[0]
        user_id = results.values.flatten[1].to_i
        automated_response = event.respond "Please enter the time & description of the #{event.command.name} (MM/DD/YY HH:MM AM/PM, Title, Message)"
        response = event.user.await!
        eventArr = response.message.content.split(/,\s*/)
        date = eventArr[0] + " " + timezone
        title = eventArr[1]
        message = eventArr[2]
        Bot::DB.prepare('addtime', "
            INSERT INTO events 
            VALUES (DEFAULT, DEFAULT, $1::text, $2::timestamptz, $3::int, $4::text)
            RETURNING event_id, reminder_time - creation_time;
        ")
        results = Bot::DB.exec_prepared('addtime', [title, date, event_type, message])
        # binding.pry
        event_id = results.values.flatten[0].to_i
        time_till = results.values.flatten[1]
        Bot::DB.exec("DEALLOCATE addtime;")
        if !results.values.empty?
            Bot::DB.exec("
                INSERT INTO user_events 
                VALUES (#{user_id}, #{event_id});
            ")
            event.respond ">>> Event created by #{event.user.name} for #{time_till} from now."
            event.channel.delete_messages([event.message, automated_response, response.message])
            results.clear
        else
            event.respond "Event Registration Error"
        end
    elsif event.command.name === :reminder
        event_type = 2
        results = Bot::DB.exec("SELECT timezone, user_id from users WHERE discord_id = #{discord_id};")
        timezone = results.values.flatten[0]
        user_id = results.values.flatten[1].to_i
        automated_response = event.respond "Please enter the time & description of the #{event.command.name} (MM/DD/YY HH:MM AM/PM, Title, Message)"
        response = event.user.await!
        eventArr = response.message.content.split(/,\s*/)
        date = eventArr[0] + " " + timezone
        title = eventArr[1]
        message = eventArr[2]
        Bot::DB.prepare('addtime', "
            INSERT INTO events 
            VALUES (DEFAULT, DEFAULT, $1::text, $2::timestamptz, $3::int, $4::text)
            RETURNING event_id, reminder_time - creation_time;
        ")
        results = Bot::DB.exec_prepared('addtime', [title, date, event_type, message])
        # binding.pry
        event_id = results.values.flatten[0].to_i
        time_till = results.values.flatten[1]
        Bot::DB.exec("DEALLOCATE addtime;")
        if !results.values.empty?
            Bot::DB.exec("
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
end
