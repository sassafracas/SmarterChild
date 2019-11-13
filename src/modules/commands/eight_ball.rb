module Bot::DiscordCommands
    # A simple eight ball fortune module
    # It gives back a random decision out of 22 possible ones
    module EightBall
        extend Discordrb::Commands::CommandContainer
      
        command(:ball, description: 'Let the shake of an 8-ball determine your future.') do |event|
            options = [
                'It is certain', 'It is decidedly so', 'Without a doubt',
                'Yes, definitely', 'You may rely on it', 'You can count on it', 'As I see it, yes',
                'Most likely', 'Outlook good', 'Yes', 'Signs point to yes',
                'Reply hazy try again', 'Ask again later', 'Better not tell you now',
                'Cannot predict now', 'Concentrate and ask again', 'Don\'t count on it',
                'My reply is no', 'My sources say no', 'Outlook not so good',
                'Very doubtful', 'Chances aren\'t good' 
            ]
        
            event.respond("🎱#{options[rand(0..21)]}🎱")
        end
    end
end