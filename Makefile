.PHONY: put get poll

poll: data

get:
	cp -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/ZZPsijicHall.lua data/
	-cp -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/LibDebugLogger.lua data/

getpts:
	cp -f /Volumes/Elder\ Scrolls\ Online/pts/SavedVariables/ZZPsijicHall.lua data/
	-cp -f /Volumes/Elder\ Scrolls\ Online/pts/SavedVariables/LibDebugLogger.lua data/

put:
	cp -f ./ZZPsijicHall.txt      /Volumes/Elder\ Scrolls\ Online/live/AddOns/ZZPsijicHall/
	cp -f ./ZZPsijicHall.lua      /Volumes/Elder\ Scrolls\ Online/live/AddOns/ZZPsijicHall/


