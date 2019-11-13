module Bot::DiscordEvents
    # This event happens whenever someone says 'dank'.
    module Dank
        extend Discordrb::EventContainer

        message(contains: 'dank') do |event|
            event.respond('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
        end
    end
end