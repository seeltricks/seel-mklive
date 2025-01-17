#!/bin/bash

case $1 in
	selected-region)
		# Take a screenshot of the selected region
		grim -t jpeg -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%m-%s).jpg
		;;
	save-to-clipboard)
		# Take a screenshot and save it to the clipboard
		grim -g "$(slurp -d)" - | wl-copy
		;;
	focused-window)
		# Take a screenshot of the focused window
		pos=$(qtile cmd-obj -o window -f get_position | awk '{ print $1" "$2}' | tr -dc '0-9 ')
		xpos=$(echo $pos | awk '{ print $1 }')
		ypos=$(echo $pos | awk '{ print $2 }')
		size=$(qtile cmd-obj -o window -f get_size | awk '{ print $1" "$2}' | tr -dc '0-9 ')
		xsize=$(echo $size | awk '{ print $1 }')
		ysize=$(echo $size | awk '{ print $2 }')
		xsize=$((xsize+4)) # Value added is 2 times the border width
		ysize=$((ysize+4)) # Value added is 2 times the border width
		grim -g "$xpos"",""$ypos $xsize""x""$ysize" -t jpeg ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%m-%s).jpg
		;;
		*)
		# Take a screenshot of the currently focused output and save it into screenshots
		output="$(qtile cmd-obj -o core -f eval -a "self._current_output.wlr_output.name" | awk -F"['']" '/,/{print $2}')"
		grim -o $output -t jpeg ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%m-%s).jpg
		;;
esac
