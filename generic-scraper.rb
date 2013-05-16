require 'nokogiri'
require 'open-uri'

# searches links for contact links and grabs emails from the links
def find_contact_link(link)
  emails = []
  begin
    doc = Nokogiri::HTML(open(link))
    doc.css("a").each do |a|
      if a.text.downcase.include? 'contact' \
        or a.text.downcase.include? 'about'
          emails = get_email_from_link(URI.join(args[:link], a['href']))
      end
    end
  rescue StandardError => e
  end
  emails
end


# grabs all emails on a specific page
def get_email_from_link(link)
  emails = []
  begin
    doc = Nokogiri::HTML(open(link))
    puts link
    string = doc.xpath("//text()").to_s
    emails = extract_emails_to_array string
  rescue StandardError => e
    error = true
  end
  emails
end

def extract_emails_to_array(txt)
  reg = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
  txt.scan(reg).uniq
end


def get_website_link_from_link(link)
  puts link
  doc = Nokogiri::HTML(open(link))
  doc.css('label').each { |label|
    puts label.text if label.text.downcase.include? 'web site'
  }
end

list_link = 'http://www.clmp.org/directory/'
#list_link = 'http://www.failbetter.com/Links.php'
doc = Nokogiri::HTML(open(list_link))
doc.css("a").each do |a|
  name = a.text
  get_website_link_from_link URI.join(list_link, a['href'])

#
#  emails_on_page = get_email_from_link URI.join(list_link, a['href'])
#  emails_from_contact_pages = find_contact_link :link =>a['href']
#  all_emails = emails_on_page + emails_from_contact_pages
#  all_emails.each { |email| puts "#{name}, #{email}" } unless all_emails.empty?
#
end


