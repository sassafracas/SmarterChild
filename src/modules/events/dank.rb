module Bot::DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Dank
        extend Discordrb::EventContainer

        message(contains: 'dank') do |event|
            event.respond('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
        end
    end
end