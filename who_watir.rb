require 'watir'

$browser = Watir::Browser.new

$browser.goto('https://www.whoscored.com/Regions/252/Tournaments/2/England-Premier-League')

#Shortcut for appending to the json file in the current directory

def file_out(string)
open('myfile.json', 'a') { |f|
    f.puts string
  }
end

#wait until the xpath element is present and then click on it

def wait_click_e(xpath)
    $browser.element(:xpath => xpath).wait_until(&:present?).click
end

#wait until the xpath element is present before continuing

def wait_for_e(xpath)
    $browser.element(:xpath => xpath).wait_until(&:present?)
end

#Select the specific stats table from the drop down menu

def select_stats_list(list, value)
    case list
        when "category" then $browser.select_list(:xpath => '//*[@id="category"]').select(value)
            file_out('{ "' + value + '": ')
        else $browser.select_list(:xpath => '//*[@id="statsAccumulationType"]').select(value)
    end
    

end

#grab the whole table and write to the json file

def get_full_table()
    stats_table = '//*[@id="statistics-table-detailed"]//*[@id="player-table-statistics-body"]'
    #puts stats_table
    wait_click_e('//*[@id="player-tournament-stats-options"]/li[5]/a')

    row_count = $browser.element(:xpath => '//*[@id="statistics-table-detailed"]//*[@id="player-table-statistics-body"]').wait_until.trs.count
    #puts row_count

    row = $browser.element(:xpath => '//*[@id="statistics-table-detailed"]//*[@id="player-table-statistics-body"]').wait_until
    sleep(0.5)
    row.trs.each do |tr|
        sleep(0.5)
        tr.each do |cell|
            cell_key = cell.class_name.gsub("sorted", "")
            cell_key = cell_key.gsub(" ", "")
            cell_value = cell.inner_html.gsub("-", "0")
            cell_text = cell.inner_text
            
            if cell.inner_html.length > 25
                unless cell_text.include? "Total"
                    file_out('{ "' + cell_text + '": ')
                end
            elsif cell.class_name.length < 1
                next
            elsif cell_value.include?("strong")
                next
            elsif cell.inner_html != nil
                file_out('{ "' + cell_key + '": "' + cell_value + '" }')
                if cell_key.include? "rating"
                    file_out(' }')
                end
            else
                next
            end
        end
        
    end
    file_out(" }")
end

#Get a list of links for each team in the premiership, this is based on table position

def get_each_team()

    prem_table = '//*[@id="standings-16368-content"]'
    row_count = $browser.element(:xpath => prem_table).wait_until.trs.count
    teams_links = {}

    for i in 1..row_count do
        team_path = $browser.element(:xpath => prem_table + '/tr[' + i.to_s + ']/td[2]/a')
        team_name = team_path.inner_html
        team_link = team_path.parent.a.href
        teams_links.store(team_name, team_link)
        #puts teams_links
    end
    return teams_links
end

#from a team grab a list of links for each player, this is sorted by rating

def get_each_player()

    player_table = '//*[@id="player-table-statistics-body"]'
    row_count = $browser.element(:xpath => player_table).wait_until.trs.count
    player_links = {}

    for i in 1..row_count do
        player_path = $browser.element(:xpath => player_table + '/tr[' + i.to_s + ']/td[3]/a')
        player_name = player_path.inner_html
        player_link = player_path.parent.a.href
        player_links.store(player_name, player_link)
    end
    #puts player_links
    return player_links
end



number_of_teams = get_each_team().length
teams = get_each_team()

for i in 0...number_of_teams do
    #puts number_of_teams
    team = teams.keys[i]
    link = teams.values[i]
    #puts team
    #puts link
    $browser.goto(link)

    file_out('{ "' + team + '": ')

    #number_of_players = get_each_player().length
    players = get_each_player()

    for i in 0..1 do
    #for i in 0...number_of_players do
        player = players.keys[i]
        player_link = players.values[i]
        #puts player
        #puts link
        $browser.goto(player_link)
        file_out('{ "' + player + '": ')
        wait_click_e('//*[@id="player-tournament-stats-options"]/li[5]/a')
        
        select_stats_list("Accumulation", "Per 90 mins")
        
        select_stats_list("category","Tackles")
        #begin
        get_full_table()
        #rescue
            #sleep(1)
            #retry
        #end

        
        # select_stats_list("category","Interception")
        # get_full_table()
        
        # select_stats_list("category","Cards")
        # get_full_table()
        
        # select_stats_list("category","Offsides")
        # get_full_table()       
        
        # select_stats_list("category","Clearances")
        # get_full_table()
        
        # select_stats_list("category","Blocks")
        # get_full_table()

        # select_stats_list("category","Saves")
        # get_full_table()

        # select_stats_list("category","Shots")
        # get_full_table()

        # select_stats_list("category","Goals")
        # get_full_table()

        # select_stats_list("category","Dribbles")
        # get_full_table()

        # select_stats_list("category","Possession loss")
        # get_full_table()

        # select_stats_list("category","Aerial")
        # get_full_table()

        # select_stats_list("category","Passes")
        # get_full_table()

        select_stats_list("category","Key passes")
        get_full_table()

        select_stats_list("category","Assists")
        get_full_table()
        
        file_out(" }")

    end

    file_out(" }")
end
$browser.close



