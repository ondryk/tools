#iFauna notifier

Simple script that checks new advertisements on [iFauna](http://ifauna.cz) server and sends email notifications.
It requires ruby 2.3.0 and some gems installed.
For your ruby installation please install following gems:

    gem install nokogiri --no-ri --no-rdoc
    gem install pony --no-ri --no-rdoc

After that adjust *config.rb* file with your settings and setup cron to run *if-watch.rb* periodically, eg. every 5 minutes.

    */5             *       *               *       *               su user -c 'cd /opt/bin && ./if-watch.rb'   
