module Bot::DiscordCommands
    # A reminder
    # It can add, subtract, multiply, and divide
    module Reminder
        extend Discordrb::Commands::CommandContainer

        command(%i[reminder event], usage: 'Remind me') do |event|
            if is_registered?(event)
                register_user(event)
                user_data = get_user_info(event)
                add_user_to_db(event, user_data)
            else
                create_user_event(event)
            end
        end
    end
end