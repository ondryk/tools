#Where to send notification
ALERT_EMAIL="your_email@gmail.com"
ALERT_SUBJECT='iFauna notification'

#smtp info, we assume TLS, as it should be standard nowadays
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
SMTP_NAME="your_email@gmail.com"
SMTP_PASS="password"

#history file with matched advertisments
#if deleted, or empty, notifications will be send again as there is no other way
#how to check if we notified in past
HISTORY="/tmp/page-watch-history.txt"


#Example watch
WATCHES = [
    AdvSearch.new("Burunduk",
                  "http://www.ifauna.cz/drobni-savci/inzerce/r/?q=&psc=&okoli=25&kraj=&CenaMin=&CenaMax=&Filter1=0&typ=0&stari=0",
                  Array["vakoveverk","burundu"]),
    AdvSearch.new("Morce",
              "http://www.ifauna.cz/drobni-savci/inzerce/r/?q=&psc=&okoli=25&kraj=&CenaMin=&CenaMax=&Filter1=0&typ=0&stari=0",
              Array["morč"])
]
