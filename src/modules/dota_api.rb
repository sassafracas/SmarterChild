def make_web_request(url)
    data = RestClient.get(url)
    JSON.parse(data)
end

def most_recent_dota_game(account_id)
    header = "account_id=#{account_id}"
    valve_key = ENV['VALVE_KEY']
    url = "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?#{header}&key=#{valve_key}"
    all_recent_games_hash = make_web_request(url)
    all_recent_games_hash
  end