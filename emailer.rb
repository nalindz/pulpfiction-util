#! /usr/bin/env ruby
# encoding: utf-8
require 'sqlite3'
require 'mail'
require 'nokogiri'
require 'open-uri'
require 'uri'


$your_name = "Nalin"
$from_address = "Nalin <nalin@pulpfictionapp.com>"

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'your.host.name',
            :user_name            => 'pulpfictionapp@gmail.com',
            :password             => 'thecatsaysmeow',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end


def send_mail(args = {})
  return if has_email_been_messaged? args[:to_address]
  insert_email(args[:to_address])

  text_body = "Hi!

My name is #{$your_name} and I'm part of and team that's developing Pulp Fiction, an online platform for writers to showcase and share their work. Think of it as Youtube or SoundCloud, but for fiction. We've finished developing the prototype and we're currently reaching out to authors & aspiring writers who would be interested in sharing their work on this platform.

We’re really excited about this since we feel that this is the next step in bringing works of fiction to a new audience. Art such as music and photography are easily shared and discovered by people online, so why not fiction?

I was wondering if #{args[:magazine_name]} would be interested in sharing some work and being amongst the first content on our platform. We see this as similar to music artists having their own YouTube channel. It could give #{args[:magazine_name]} some new exposure and showcase some of the content that's been published on it. I’d also love to hear if you have any questions/comments about the platform. For more information, feel free to checkout our website at http://www.pulpfictionapp.com

You can check out a quick demo of the app (currently for iPad) below here:
https://www.youtube.com/watch?v=zwJeCijimv4&hd=1


Thanks!
#{$your_name}"

  mail = Mail.new do
    from $from_address
    to args[:to_address]
#    to "nalindz@gmail.com"
    subject "Pulp Fiction"
    text_part do
      body text_body
    end
  end

#  puts mail
  mail.deliver!
  puts "email sent to: #{args[:to_address]}"
end

def init_db
  $db = SQLite3::Database.new "messaged.db"
  $db.execute("CREATE TABLE IF NOT EXISTS emailed(id integer primary key, email VARCHAR(30) NOT NULL)")
  $db.execute("CREATE UNIQUE INDEX IF NOT EXISTS UniqueEmail ON emailed (email)")
end

def insert_email(email)
  begin
    $db.execute("INSERT INTO emailed (email) VALUES (?)", email)
  rescue SQLite3::ConstraintException => e
    return false
  end
  return true
end

def has_email_been_messaged?(email)
  $db.execute("SELECT email from emailed where email = ?", email).count > 0
end

################

init_db
input_emails = File.readlines(ARGV[0]).each do |line|
  email_details = line.split(',')
  send_mail :to_address => email_details[0], :magazine_name => email_details[1].strip
end
