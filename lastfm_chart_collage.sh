#!/bin/bash

########################################################################
# This script is designed to create a collage from the respective user's
# last.fm charts. Based off the 2.0 API, and uses curl
########################################################################

TEMPDIR=$(mktemp -d)
touch $TEMPDIR/tempjson.json
TEMPJSON=$(echo "$TEMPDIR/tempjson.json")

########################################################################
# This is for my imgholder script which will download a stock image when
# nothing else is available
########################################################################
imgholder_location=$(which imgholder.sh)

if [ -f "$HOME/.config/lastfm_collage.rc" ];then
    readarray -t line < "$HOME/.config/lastfm_collage.rc"
    API_KEY=${line[0]}
    USER=${line[1]}
    PERIOD=${line[2]}
    OUTPUTDIR=${line[3]}
fi


if [ -z "$API_KEY" ]; then
    echo "Configuration file not set up properly."
    exit
fi


################################################################################
# Get JSON from Last.FM
################################################################################
curl_time() {

METHOD=user.gettopalbums

curl_line="http://ws.audioscrobbler.com/2.0/?method=$METHOD&period=$PERIOD&user=$USER&api_key=$API_KEY&limit=9&format=json"
curl "$curl_line"  > "$TEMPJSON"

}

################################################################################
# Parse json from Last.FM and get the images
################################################################################

parse_json() {
    albumname=()
    imageurl=()
    #loop here from 0-7
    for i in {0..7}
    do
        toadd=$(cat "$TEMPJSON" | jq '.topalbums | .album | '".[$i]"' | @text "\(.name)"' | awk -F '"' '{print $2}') 
        albumname=("${albumname[@]}" "$toadd")
        toadd=$(cat "$TEMPJSON" | jq -M  '.topalbums | .album | '".[$i]"' | .image' | grep -B1 -w "extralarge" | grep -v "extralarge" | awk -F '"' '{print $4}')  
        imageurl=("${imageurl[@]}" "$toadd")
        echo "${albumname[i]}"
        echo "${imageurl[i]}" 
        
        # No image; try imgholder
        if [ ! -z "${imageurl[i]}" ];then
            wget -O "$TEMPDIR/$i.png" "${imageurl[i]}"
        else
            if [ ! -z "$imgholder_location" ];then
                bob=$($imgholder_location -o "$TEMPDIR/$i.png")
            fi
        fi 

        
        # Commented out because it tends to cover up the albums; maybe eventually I'll add it back in
        # Please note that if 
        #convert -size 256x128 -background none -fill white -stroke black -strokewidth 0.01 -font Interstate  -gravity SouthWest caption:"${albumname[i]}" "$TEMPDIR/Text$i.png"  
          
        #composite -gravity SouthWest "$TEMPDIR/Text$i.png" "$TEMPDIR/$i.png" "$TEMPDIR/$i.jpg"
        
    done
}

################################################################################
# Make into collage and output
################################################################################
make_collage() {
    montage $TEMPDIR/*.png -geometry 256x256+0+0 -tile 4x2 $TEMPDIR/collage.jpg
    DATE=`date +%Y-%m-%d`
    cp -f $TEMPDIR/collage.jpg $OUTPUTDIR/$DATE.jpg
    cp -f $TEMPDIR/collage.jpg $OUTPUTDIR/current_collage.jpg 
}

################################################################################
# Cleanup TEMPDIR.
################################################################################
cleanup() {
    rm $TEMPDIR/*.png
    rm $TEMPDIR/*.json
    rm $TEMPDIR/*.jpg
    rmdir $TEMPDIR
}


################################################################################
# Wherein things get told to happen
################################################################################
main() {
#  parse_variables
 # check_variables
    curl_time
    parse_json
    make_collage
    cleanup
	exit 0
}

main
