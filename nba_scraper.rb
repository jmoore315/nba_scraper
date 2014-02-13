require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'watir'

BASE_URL = "http://www.nba.com/playerfile/"

output = File.open("output.xls", "w")
browser = Watir::Browser.new :safari


players = ["Russell Westbrook", "Carmelo Anthony", "Deron Williams", "John Wall", "Mike Conley", "Luol Deng", "Marc Gasol", "Lebron James", "Stephen Curry", "Dwight Howard", "Damian Lillard", "Anthony Davis", "Kobe Bryant", "Chris Bosh", "Paul George", "Kyrie Irving", "Tony Parker", "Dwyane Wade", "Dirk Nowitzki", "Tim Duncan", "Roy Hibbert", "James Harden", "Chris Paul", "Lamarcus Aldridge", "Ty Lawson", "Monta Ellis", "Rudy Gay", "Zach Randolph", "Kevin Durant", "Kevin Love", "Blake Griffin", "DeMarcus Cousins", "Klay Thompson", "Eric Bledsoe", "Al Jefferson"]

output.write "Players\tPPG\tAPG\tRPG\tBlocks PG\tSteals PG\tReg Season Win %\tTotal (PPG + APG + 0.75*RPG +BPG + SPG - TPG + 20*(Win% - 0.5)\n"
	
i = 1

for player in players do
	begin
		player_url = "#{BASE_URL}#{player.downcase.gsub(/ /, '_')}/"
		page = Nokogiri::HTML(open(player_url))

		rescue OpenURI::HTTPError => e
			if e.message == '404 Not Found'
				puts player
				puts player_url
			else
				raise e
			end
		end

		stats_link = page.css('a#tab-stats')
		stats_url = stats_link[1]['href']
		begin
			#page = Nokogiri::HTML(open(stats_url))
			browser.goto stats_url
			browser.td(:class => "col-GROUP_VALUE").wait_until_present
			page = Nokogiri::HTML.parse(browser.html)

			rescue 
				if e.message == '404 Not Found'
					puts stats_url
				else
					raise e
				end
			end

			
			pts = page.css('table.season.quickstats td.PTS')[0].text.to_f
			assists = page.css('table.season.quickstats td.AST')[0].text.to_f
			rebounds = page.css('table.season.quickstats td.REB')[0].text.to_f
			win_rate = page.css('td.col-W_PCT')[0].text.to_f
			steals = page.css('td.col-STL')[0].text.to_f
			blocks = page.css('td.col-BLK')[0].text.to_f


			output.write player
			output.write "\t#{pts}"
			output.write "\t#{assists}"
			output.write "\t#{rebounds}"
			output.write "\t#{blocks}"
			output.write "\t#{steals}"
			output.write "\t#{win_rate}"
			output.write "\t#{pts + assists + 0.75*rebounds + steals + blocks + 20*(win_rate - 0.5)}"
			

	output.write "\n"
	output.write "\n\n\n" if i%7 == 0
	i+=1
end


output.close






