Interview Questions
===================
What I realized after a year in 'real life', your focus and scope of 'real life' coding work can be severely
limited to a specific domain. To keep myself marketable and to constantly improve my coding skills in all
aspects, I have decided to practice coding interview questions. I may not need to worry about bit-manipulation or
optimizations, but my next job may.

This can be discovered in the `interview-qs` folder

Website Bots
============
After I learned the wonderful gem [https://github.com/jnicklas/capybara](Capybara) and discovered
[https://github.com/cpitt/bingbot](bingbot), I extended my knowledge of this to create many other
website crawler/bots that would help with my life immensely. Notably, there are three (right now):
  * Bing bot - 'nuff said
  * GOES bot - This logs on [goes-app.cbp.dhs.gov](Global Entry) online portal, and selects an earlier
    appointment time if there is one available. I assum you are conditionally approved at this point.
    I used this with my NEXUS application. With this script cron'd at every twenty minutes, 
    I managed to secure an interview slot three months earlier than the next available slot (someone canceled)
  * AT&T bot - This logs on [https://www.wireless.att.com](AT&T Wireless) online account portal, get
    the billing summary, average out the family plan, divvy out the cell phone charges, and send an email out.

This can be discovered in the `/website-bots` folder.

Tag Facebook Photos
===================
A little script which immensenly helped me when I upload photos. The great thing about sharing pictures on Facebook is
the ability to tag people. Now, uploading from Lightroom (where I do my editing and processing) doesn't do it automagically,
and I've already done the painstakingly hard job in Lightroom already - I don't want to put myself to doing that again!
So this script will parse the EXIF tags incorporated in each picture, and find if the keyword is in usermapping.
If it is, it will call Facebook API to tag the person
