#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'rubygems'
require 'nokogiri'
require 'pony'


class AdvSearch
  attr_reader :title, :url, :words
  def initialize(title, url, words)
   @title = title #Just for you, indetification of watcher
   @url = url # what page to watch
   @words = words #array of keywords
  end
end

require './config'


#open page and return as string
#Params:
#+url+:: string url to open
#Return:: string content of page
def open_page(url)
  Net::HTTP.get(URI.parse(url))
end

#Check if page has given word
#Return: true if word is found
def has_word(page, adv)
  adverts = page.css('div.inz-text')

  alerts = Array[]
  adv.words.each do |kw|
    adverts.each do |t|
      if t.to_s.downcase().include? kw
        alerts.push ({t => adv})
      end
    end

  end
  send_alert(alerts)
end



#send email alert and save new items

def send_alert(alerts)
  send = Array[]
  alerts.each do |a|
    a.each do |adv,search|
      link = adv.css('a')
      hash = createsig(link.to_s)
      if (!already_notified(hash))
        send.push ({adv => search})
      end
    end
  end


  holder = File.open(HISTORY, 'a')
  body = ""
  send.each do |s|

    s.each do |adv, search|
      href = adv.css('a')
      title_str = href.text()
      link = href.to_s
      holder.puts "#{link}|#{createsig(link)}"
      info =  "#{search.title} : Advert <a href=\"#{search.url}\">#{title_str}</a> contains some of keywords #{search.words}"
      puts info
      body += info +"\n<br />"
    end
  end
  #send email onnly if something was found
  if send.length > 0
    send_mail(body)
  end
  holder.close
end

#send email with given content
def send_mail(content)
  Pony.mail({
      :html_body => content,
      :subject => ALERT_SUBJECT,
      :to => ALERT_EMAIL,
      :via => :smtp,
      :via_options => {
          :charset              => 'utf8',
          :address              => SMTP_HOST,
          :port                 => SMTP_PORT,
          :enable_starttls_auto => true,
          :user_name            => SMTP_NAME,
          :password             => SMTP_PASS,
          :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
          :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
      }
  })
end

#create hash of given string
def createsig(body)
  Digest::MD5.hexdigest( body )
end

#check if given hash was already notified
def already_notified(hash)
  file = HISTORY
  if (!File.exist?(file))
    return false
  end
  holder = File.open(file, 'r')
  holder.each_line { |l|
    line = l.sub("\n",'').split('|')
    if (line[1] == hash)
      holder.close();
      return true
    end
  }
  holder.close()
  return false
end

WATCHES.each do |w|
  puts "Checking #{w.title}"
  npage = Nokogiri::HTML(open_page(w.url))
  advs = npage.css("div#inzerce-container")[0]

  has_word(advs, w)
end
