# lastfm_chart_services

There's a Last.FM collage generator at http://tapmusic.net/ which is 
good and fine (and I donated money to them as well). But I wanted to 
self-host, get a little more experience with REST APIs (even if it's 
with CURL) and imagemagick, so I'm aiming to recreate it here with bash. 
That and all the freaking Last.FM repositories I'm finding have problems 
of some kind or another. Le sigh.

This implies that you're going to have some way to post to social media 
automagically like ttytter (or the project that's replaced it).

#TODO (yeah, all of it)

* Get the *current* or *last* track of the user in question. This could replace the functionality we used to have with RSS feeds.
* Post a current track with the album art!
* Top albums for 7d and top artists for 7d, then parse out the image urls (or see if they're in a local directory!) and make up the collage
