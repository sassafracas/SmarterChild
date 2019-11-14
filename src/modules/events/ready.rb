module Bot::DiscordEvents
    # This checks the db as soon as the bot is loaded
    module Ready
        extend Discordrb::EventContainer

        ready do |event|
            check_db_for_events
            Thread.new do
                loop do 
                    sleep 60
                    check_db_for_events
                end
            end
        end
    end
end