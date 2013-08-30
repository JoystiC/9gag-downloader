#/bin/bash
# ==== Automatic downloader for 9gag.com ====
# variable time is delay between check if there is some new posts
# coded by Peter Skyva
# 

time=600

function downloader() {
	
	#####
	# download source code and get links to pictures
	#####

	echo "Downloading source code of 9gag.com..."
	curl 9gag.com > source 2>&-
	grep -oh '\http://9gag.com/gag/[a-zA-Z0-9]*' source > res
	touch links
	touch picture
	# Create dir ./pictures if not exist
	if [ -d ./pictures ]; then	
		touch ./pictures/picture
	else
		mkdir ./pictures
	fi
	# Get all the links from front page
	echo "Getting links to pictures..."
	while read data; do
		if grep -Fxq "$data" links; then
			continue
		else
			echo "$data" >> links
		fi
	done < res
	rm res source

	#####
	# visit links, get links to picture -> save link to file picutres 
	#####

	echo "Visiting links and saving picture URL..."
	# getting all URL to pictures or Gifs
	while read data; do
		curl "$data" > source 2>&-
		if grep -oh -m 1 -q 'http://[a-zA-Z0-9]*.cloudfront.net/photo/[a-zA-Z0-9]*_[a-zA-Z0-9]*.gif' source; then
			grep -oh -m 1 -q 'http://[a-zA-Z0-9]*.cloudfront.net/photo/[a-zA-Z0-9]*_[a-zA-Z0-9]*.gif' source >> picture
		else
			grep -oh -m 1 'http://[a-zA-Z0-9]*.cloudfront.net/photo/[a-zA-Z0-9]*_700b[_[a-zA-Z0-9]*]*.jpg' source >> picture	
		fi
	done < links

	#####
	# downloads pictures to folder ./pictures
	#####

	echo "Downloading pictures..."
	# download only pictures you dont already got
	while read data; do
		if grep -q "$data" ./pictures/picture; then
			continue
		else
			wget -P ./pictures "$data"
		fi
	done < picture

	# move file picture to recognize which pictures-gis you got
	mv picture ./pictures
	rm links source
}

# while cycle for automatic downloading 
# sleep {secunds} can be set different for better results
while true; do
	downloader
	sleep $time
done






