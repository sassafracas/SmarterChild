module Bot::DiscordEvents
    # This pms a user when bot is mentioned (will replace with something more useful)
    module Mention
        extend Discordrb::EventContainer

        mention do |event|
            event.user.pm("Hey #{event.user.name}, don't tell anyone we talked.")
        end
    end
end