module Bot::DiscordCommands
    # A module to get dota stats
    # It spits back a link to the last game of three possible players
    module Dota
        extend Discordrb::Commands::CommandContainer

        command(:dota2_a, description: "Show the last Dota 2 Game of Alienated.") do |event|
            hash = most_recent_dota_game(12540712)
            recent_game_match_id = hash["result"]["matches"][0]["match_id"]
            opendota_url = "https://www.opendota.com/matches/#{recent_game_match_id}"
            event.respond(opendota_url)
        end
        
        command(:dota2_g, description: "Show the last Dota 2 Game of Gingervitis.") do |event|
            hash = most_recent_dota_game(34933397)
            recent_game_match_id = hash["result"]["matches"][0]["match_id"]
            opendota_url = "https://www.opendota.com/matches/#{recent_game_match_id}"
            event.respond(opendota_url)
        end
        
        command(:dota2_t, description: "Show the last Dota 2 Game of Teebs.") do |event|
            hash = most_recent_dota_game(2148619)
            recent_game_match_id = hash["result"]["matches"][0]["match_id"]
            opendota_url = "https://www.opendota.com/matches/#{recent_game_match_id}"
            event.respond(opendota_url)
        end
    end
end

