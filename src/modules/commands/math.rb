module Bot::DiscordCommands
    # A simple math module
    # It can add, subtract, multiply, and divide
    module Math
        extend Discordrb::Commands::CommandContainer

        command(:add, usage: 'Adds any amount of numbers together.') do |event, *integers|
        integers.map{|int| int.to_i}.inject{|sum,x| sum + x }
        end
        
        command(:multiply, description: 'Multiplies any amount of numbers together.') do |event, *integers|
        integers.map{|int| int.to_i}.inject{|product,x| product * x }
        end
        
        command(:subtract, description: 'Subtracts all the numbers given.') do |event, *integers|
        integers.map{|int| int.to_i}.inject{|difference,x| difference - x }
        end
        
        command(:divide, description: 'Divides all the numbers given.') do |event, *integers|
        integers.map{|int| int.to_f}.inject{|quotient,x| quotient / x }
        end
    end
end