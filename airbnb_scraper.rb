require 'nokogiri'
require 'open-uri'
require 'csv'

# Store URL to be scraped
url = "https://www.airbnb.com/s/Sacramento-CA--United-States"

# Parse the page with Nokogiri
page = Nokogiri::HTML(open(url))

# Scrape the max number of pages and store in max_page variable
page_numbers = []
page.css("div.pagination ul li a[target]").each do |l|
	page_numbers << l.text
end

max_page = page_numbers[0...-1].map(&:to_i).max

# Initialize arrays
name = []
price = []
details = []

max_page.to_i.times do |i|

	# Parse page with Nokogiri
	url = "https://www.airbnb.com/s/Sacramento-CA--United-States?page=#{i+1}"
	page = Nokogiri::HTML(open(url))
	# Store data in arrays
	page.css('h3.h5.listing-name.text-truncate.row-space-top-1').each do |l|
		name << l.text.strip.split(/;/)
	end
	page.css('span.h3.text-contrast.price-amount').each do |l|
		price << l.text
	end
	page.css('div.text-muted.listing-location.text-truncate').each do |l|
		details << l.text.strip.split(/ · /)
	end
end

# Write data to csv file 
CSV.open("airbnb_listings.csv", "w") do |f|
	f << ["Listing Name", "Price", "Room Type", "Reviews"]

	name.length.times do |i|
		if details[i].length == 1
			f << [name[i], price[i], details[i][0], "N/A"]
		elsif details[i].length == 2
			f << [name[i], price[i], details[i][0], details[i][1]]
		elsif details[i].length == 3
			f << [name[i], price[i], details[i][0], details[i][2]]
		end
	end
end
