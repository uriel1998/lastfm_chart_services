# lastfm_chart_services

There's a Last.FM collage generator at http://tapmusic.net/ which is 
good and fine (and I donated money to them as well). But I wanted to 
self-host, get a little more experience with REST APIs (even if it's 
with CURL) and imagemagick, so I'm aiming to recreate it here with bash
and formatted the way I want it. 

![Example](https://s26.postimg.org/45icvxk3t/current_collage.jpg)

This implies that you're going to have some way to post to social media 
automagically like ttytter (or the project that's replaced it).

# Requires

* curl
* [jq](https://github.com/stedolan/jq)
* awk
* [imagemagick](http://www.imagemagick.org)
* last.fm account (duh) and [API key](https://www.last.fm/api)

# Usage

Make sure you get a last.fm API key.  :)

Create lastfm_collage.rc in $HOME/.config with these lines (in order!)
```
YOUR_API_KEY
YOUR_USERNAME
7day
/DIRECTORY/FOR/OUTPUT
```

Then run the script!
