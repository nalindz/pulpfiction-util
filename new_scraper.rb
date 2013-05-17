require 'nokogiri'
require 'open-uri'
require 'json'


list_link = 'http://www.failbetter.com/Links.php'
links_hash = Hash.new ""
doc = Nokogiri::HTML(open(list_link))
doc.css("a").each do |a|
	name = a.text.strip
  name = name.tr("\n","")
	links_hash[name] = a['href']
end
