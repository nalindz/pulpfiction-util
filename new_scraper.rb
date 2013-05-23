require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'

def scrape_link_for_emails(link)

  emails = get_emails_from_link(link)
  emails += get_emails_from_contact_link(link)

end

def get_emails_from_contact_link(link)
  emails = []
  begin
    doc = Nokogiri::HTML(open(link))
    doc.css('a').each do |a|
      if a.text.downcase.include? 'contact' \
        or a.text.downcase.include? 'about'
          emails = get_emails_from_link URI.join(link, a['href'])
      end
    end
  rescue StandardError => e
    puts e
  end
  emails

end

def get_emails_from_link(link)
  puts 'scraping link: ' + link.to_s
  emails = []
  begin
    doc = Nokogiri::HTML(open(link))
    string = doc.xpath("//text()").to_s
    emails = extract_emails_to_array string

    # check all links on page for mailto emails
    doc.css('a').each do |a|
      if a['href'].to_s.include?('mailto')
        address = a['href'].split(':')[1]
        unless emails.include?(address)
          emails << address
        end
      end
    end

  rescue StandardError => e
    puts e
  end
  emails
end

def extract_emails_to_array(txt)
  reg = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
  txt.scan(reg).uniq
end


list_link = 'http://www.failbetter.com/Links.php'
# list_link = 'http://www.azharkhan.net'
# list_link = 'http://www.identitytheory.com/'

links_hash = Hash.new ""
links_hash_copy = Hash.new "www.default.com"

begin
  doc = Nokogiri::HTML(open(list_link))
  doc.css("a").each do |a|
  	name = a.text.strip
    name = name.tr("\n","")
  	links_hash[name] = a['href']
  end
rescue StandardError => e
  puts e
end

links_hash_copy = links_hash
# CSV.open("links_names.csv", "wb") do |csv|
#   links_hash_copy.to_a.each do |link|
#     csv << link
#   end
# end

links_hash_copy.each do |name, url|
  links_hash[name] = scrape_link_for_emails URI.join(list_link, url)
end

puts JSON.pretty_generate(links_hash_copy)
puts JSON.pretty_generate(links_hash)

# CSV.open("emails.csv", "wb") do |csv|
#   CSV.open("no_emails.csv", "wb") do |ncsv|
#     links_hash.each do |key, value|
#       if value.empty?
#         puts key
#         ncsv << [key, links_hash_copy[key]]
#       else
#         csv << [value, key]
#       end
#     end
#   end
# end


  # links_hash.to_a.each do |email|
  #   unless email[1] == []
  #     csv << email
  #   end
  # end
# end




