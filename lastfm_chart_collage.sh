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
    placeholder_dir=${line[4]} 
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
    artistname=()
    #loop here from 0-7
    for i in {0..7}
    do
        toadd=$(cat "$TEMPJSON" | jq '.topalbums | .album | '".[$i]"' | .artist | .name '  | awk -F '"' '{print $2}')
        artistname=("${artistname[@]}" "$toadd")
        toadd=$(cat "$TEMPJSON" | jq '.topalbums | .album | '".[$i]"' | @text "\(.name)"' | awk -F '"' '{print $2}') 
        albumname=("${albumname[@]}" "$toadd")
        toadd=$(cat "$TEMPJSON" | jq -M  '.topalbums | .album | '".[$i]"' | .image' | grep -A1 -w "extralarge" | grep -v "extralarge" | awk -F '"' '{print $4}')  
        imageurl=("${imageurl[@]}" "$toadd")
        echo "${albumname[i]}"
        echo "${imageurl[i]}"        

        if [ ! -z "${imageurl[i]}" ];then
            wget -O "$TEMPDIR/tmp.png" "${imageurl[i]}"
            convert "$TEMPDIR/tmp.png" -resize 512x512 "$TEMPDIR/$i.png"
        else
            # No image; from lastfm; try vindauga cache, then imgholder, then cache dir
            #checking vindauga cache first
            if [ -d "$HOME/.cache/vindauga" ];then
                bob=$(find -H "$HOME/.cache/vindauga" -type f  -iname "*${albumname[i]}*" | head -1)
                if [ -f "$bob" ];then 
                    convert "$bob" -resize 512x512 "$TEMPDIR/$i.png"
                fi
            fi
        
            
            
            bob=$(file "$TEMPDIR/$i.png" | head -1)
            if [[ "$bob" != *"image data"* ]];then

                if [ ! -z "$imgholder_location" ];then
                    bob=$($imgholder_location -o "$TEMPDIR/$i.png")
                    # to avoid getting the same image multiple times
                    sleep 4
                fi
            fi
            # In case that borks up...
            bob=$(file "$TEMPDIR/$i.png" | head -1)
            if [[ "$bob" != *"image data"* ]];then
                if [ -d "$placeholder_dir" ];then
                    hasimgs=$(ls "$placeholder_dir" | egrep "jpeg|jpg|png|gif" -c )
                    if [ $hasimgs -gt 0 ]; then
                        bob=$(find -H "$placeholder_dir" -type f \( -name "*.jpg" -or -name "*.png" -or -name "*.jpeg" \) | shuf | head -1)
                        convert "$bob" "$TEMPDIR/$i.png"
                    fi
                fi
            fi
        fi 

        
        # Commented out because it tends to cover up the albums; maybe eventually I'll add it back in
        # Please note that if 
        convert -size 256x128 -background none -fill white -stroke black -strokewidth 2 -font Interstate  -gravity SouthWest caption:"${albumname[i]}" "$TEMPDIR/Text$i.png"  
          
        composite -gravity SouthWest "$TEMPDIR/Text$i.png" "$TEMPDIR/$i.png" "$TEMPDIR/$i.jpg"
        convert "$TEMPDIR/$i.jpg" "$TEMPDIR/$i.png" 
    done
}

################################################################################
# Make into collage and output
################################################################################
make_collage() {
    montage $TEMPDIR/*.png -geometry 256x256+0+0 -tile 4x2 $TEMPDIR/collage.jpg
    DATE=`date +%Y-%m-%d`
    if [ -f $TEMPDIR/collage-0.jpg ];then
        cp -f $TEMPDIR/collage-0.jpg $OUTPUTDIR/$DATE.jpg
        cp -f $TEMPDIR/collage-0.jpg $OUTPUTDIR/current_collage.jpg     
    else
        cp -f $TEMPDIR/collage.jpg $OUTPUTDIR/$DATE.jpg
        cp -f $TEMPDIR/collage.jpg $OUTPUTDIR/current_collage.jpg 
    fi
}

################################################################################
# Cleanup TEMPDIR.
################################################################################
cleanup() {
    rm $TEMPDIR/*.png
    rm $TEMPDIR/*.json
    rm $TEMPDIR/*.jpg
    #rmdir $TEMPDIR
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
