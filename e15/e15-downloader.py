#!/usr/bin/python2

import imaplib
import email 
from bs4 import BeautifulSoup
import urllib2
import re
import os
import subprocess

#CONSTANTS
#Connection to email server
IMAP_SERVER='imap.gmail.com'
IMAP_PORT=993
#Email user
USR='user@gmail.com'
PASS='password'
#Folder within IMAP that is used to search latest email
#It is necessary to have E15 emails in own folder (via email fiter) 
#as we search latest email there
IMAP_FOLDER='E15'
#Dropbox-Uploader command (see https://github.com/andreafabrizi/Dropbox-Uploader)
DBOX_UP='/usr/bin/local/dbox_up.sh'
#Downloaded temporary file from link to this location
TMP='/tmp/'
#Path within remote folder accessible by Dropbox Uploader script
DBOX_PATH='e15/'

#HELPER methods

def dlfile(loc, url):
    path = loc+os.path.basename(url)
    print 'Downloading from '+url+' to '+path
    

   # Open the url
    try:
        f = urllib2.urlopen(url)

        # Open our local file for writing
        with open(path, "wb") as local_file:
            local_file.write(f.read())

    #handle errors
    except urllib2.HTTPError, e:
        print "HTTP Error:", e.code, url
    except urllib2.URLError, e:
        print "URL Error:", e.reason, url


def dbox_up(loc, f_name):
  path = loc + f_name;
  cmd = DBOX_UP + ' upload '+path+' '+DBOX_PATH+f_name
  p = subprocess.Popen(cmd , shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  p.wait()

def get_url():
  M = imaplib.IMAP4_SSL(IMAP_SERVER, IMAP_PORT)
  rc, resp = M.login(USR, PASS)

  M.select(IMAP_FOLDER) #select folder
  result, data = M.search(None, "ALL") #get all messages from folder

  id_list = data[0].split() # data is a list of space separated id strings
  latest_email_id = id_list[-1] # get the latest
 
  result, data = M.fetch(latest_email_id, "(RFC822)") # fetch the email body (RFC822) for the given ID

  M.close()
  M.logout()

  raw_email = data[0][1]
  msg = email.message_from_string(raw_email)

  #get html part of email message from multipart message
  html = '<html><body>EMPTY</body></html>'
  for part in msg.walk():
    if part.get_content_type() == 'text/html':
      html = part.get_payload()

  #print html
  eml_bs = BeautifulSoup(html)
  
  fetch_url = eml_bs.body.find('a')['href'] #url where is the link for downloading
  e15_page = urllib2.urlopen(fetch_url)
  e15_html = e15_page.read()
  e15_page.close()

  dwn_bs = BeautifulSoup(e15_html)

  dwn_link = dwn_bs.body.find('a',attrs={'id':'download'})['href']

  return dwn_link

def remove_file(base, f_name):
  os.remove(base+f_name)


#MAIN SCRIPT
dwn_link = get_url()

#fix download link for testing
#dwn_link = 'http://file.mf.cz/pdf/e15/E15-2014-09-15.pdf'

f_name = os.path.basename(dwn_link)
#f_name = './text.sh' #debug

dlfile(TMP, dwn_link)
print 'Uploading to dropbox'
dbox_up(TMP, f_name)
print 'Removing temp file'
remove_file(TMP, f_name)

