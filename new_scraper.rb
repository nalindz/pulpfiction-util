require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'


list_link = 'http://www.failbetter.com/Links.php'
links_hash = Hash.new ""
doc = Nokogiri::HTML(open(list_link))
doc.css("a").each do |a|
	name = a.text.strip
  name = name.tr("\n","")
	links_hash[name] = a['href']
end
# puts JSON.pretty_generate(links_hash)
CSV.open("links_names.csv", "wb") do |csv|
  links_hash.to_a.each do |link|
    csv << link
  end
end
