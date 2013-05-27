require 'nokogiri'
require 'open-uri'

# searches links for contact links and grabs emails from the links
def scrape_link_for_emails(link)

  # checks if link is an email address
  # check_mailto(link)

  # grabs emails on the current page
  emails = get_emails_from_link(link)

  # grabs emails from contact/about/email links
  emails += get_emails_from_contact_link link

  # checks if page has a website field. if so, does the search
  # on that page

  website_link = get_website_link_from_link link
  unless website_link.nil?
    emails += scrape_link_for_emails website_link
  end
  emails
end


# searches for a contact link and grabs emails from there
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


# grabs all emails on a specific page
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
        emails << address
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


def get_website_link_from_link(link)

  begin
    doc = Nokogiri::HTML(open(link))
    doc.css('label').each { |label|
      if label.text.downcase.include? 'web site'
        return label.parent.css('a').first['href']
      end
    }
  rescue StandardError => e
    puts e
  end
  nil
end

# list_link = 'http://www.clmp.org/directory/'
list_link = 'http://www.bigbridge.org/links.htm'
# list_link = 'http://www.identitytheory.com/'

unable_to_scrape_links = []
all_emails = []
emails_file = File.open("emails.txt", "w")
doc = Nokogiri::HTML(open(list_link))
i = 0
doc.css("a").each do |a|
  name = a.text
  all_emails = scrape_link_for_emails URI.join(list_link, a['href'])
  if all_emails.empty?
    unable_to_scrape_links << "#{a['href']}, #{name}"
  else
    # all_emails.each { |email| puts "#{name}, #{email}" } unless all_emails.empty?
    all_emails.each { |email| emails_file.puts "#{email}, #{name}" } unless all_emails.empty?
  end
  i += 1
  break if i == 140
end

unable_to_scrape_links_file = File.open('unable_to_parse.txt', 'a')
unable_to_scrape_links.each { |line| unable_to_scrape_links_file.puts line }
