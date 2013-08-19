Website Bots
============
After I learned the wonderful gem [https://github.com/jnicklas/capybara](Capybara) and discovered
[https://github.com/cpitt/bingbot](bingbot), I extended my knowledge of this to create many other
website crawler/bots that would help with my life immensely. Notably, there are three (right now):
  * Bing bot
  * GOES bot - This logs on [goes-app.cbp.dhs.gov](Global Entry) online portal, and selects an earlier
    appointment time if there is one available. I assum you are conditionally approved at this point.
    I used this with my NEXUS application. With this script cron'd at every twenty minutes, 
    I managed to secure an interview slot three months earlier than the next available slot (someone canceled)
  * AT&T bot - This logs on [https://www.wireless.att.com](AT&T Wireless) online account portal, get
    the billing summary, average out the family plan, divvy out the cell phone charges, and send an email out.
This can be discovered in the `/website-bots` folder.
