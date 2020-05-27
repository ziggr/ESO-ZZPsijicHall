.PHONY: put get poll

poll: data

get:
	cp -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/ZZPsijicHall.lua data/
	-cp -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/LibDebugLogger.lua data/

getpts:
	cp -f /Volumes/Elder\ Scrolls\ Online/pts/SavedVariables/ZZPsijicHall.lua data/
	-cp -f /Volumes/Elder\ Scrolls\ Online/pts/SavedVariables/LibDebugLogger.lua data/

put:
	rsync -vrt --delete --exclude=.git \
	--exclude=data \
	--exclude=doc \
	--exclude=test \
	--exclude=trig \
	--exclude=published \
	--exclude=tool \
	--exclude=scratch.lua \
	. /Volumes/Elder\ Scrolls\ Online/live/AddOns/ZZPsijicHall

