require 'nokogiri'
require 'open-uri'

# searches links for contact links and grabs emails from the links
def find_contact_link(link)
  puts link

  # grabs emails on the current page
  emails = get_emails_from_link(link)

  # grabs emails from contact/about links
  emails += get_emails_from_contact_link link

  # checks if page has a website field. if so, does the search
  # on that page

  website_link = get_website_link_from_link link
  unless website_link.nil?
    emails += find_contact_link website_link
  end
  emails
end


def get_emails_from_contact_link(link)
  emails = []
  begin
    doc = Nokogiri::HTML(open(link))
    doc.css("a").each do |a|
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
  emails = []
  begin
    doc = Nokogiri::HTML(open(link))
    puts link
    string = doc.xpath("//text()").to_s
    emails = extract_emails_to_array string
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
  puts link

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

list_link = 'http://www.clmp.org/directory/'
#list_link = 'http://www.failbetter.com/Links.php'
doc = Nokogiri::HTML(open(list_link))
doc.css("a").each do |a|
  name = a.text
  all_emails = find_contact_link URI.join(list_link, a['href'])
  all_emails.each { |email| puts "#{name}, #{email}" } unless all_emails.empty?
#
end


