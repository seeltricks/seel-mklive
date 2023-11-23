#!/bin/sh

if command -v bat >/dev/null 2>&1; then
  pagercmd="bat --color=always --style=plain --pager=never"
else
  pagercmd="less -FRiX"
fi

case "$(printf "%s\n" "$(readlink -f "$1")" | awk '{print tolower($0)}')" in
  *.tgz|*.tar.gz) tar tzf "$1";;
  *.tar.bz2|*.tbz2) tar tjf "$1";;
  *.tar.txz|*.txz) xz --list "$1";;
  *.tar) tar tf "$1";;
  *.zip|*.jar|*.war|*.ear|*.oxt|*.apkg|*.apk) unzip -l "$1";;
  *.rar) unrar l "$1";;
  *.7z) 7z l "$1";;
  *.[1-8]) man "$1" | col -b ;;
  *.epub|*.rtf|*.doc|*.docx|*.odt|*.ods|*.odp|*.sxw)
	pandoc -s -t markdown -- "$1" | $pagercmd
	exit 1
	;;
  *.jpg|*.jpeg|*.png|*.bmp|*.xpm|*.gif)
        chafa -f sixel -s "$2x$3" --animate false "$1"
        exit 1
        ;;
  *.pdf)
	CACHE=$(mktemp)
	pdftoppm -png -f 1 -singlefile "$1" "$CACHE"
	chafa -f sixel -s "$2x$3" --animate false "$CACHE.png"
	rm "$CACHE"
	;;
  *.avi|*.mp4|*.wmv|*.dat|*.3gp|*.ogv|*.mkv|*.mpg|*.mpeg|*.vob|*.fl[icv]|*.m2v|*.mov|*.webm|*.ts|*.mts|*.m4v|*.r[am]|*.qt|*.divx)
	CACHE=$(mktemp)
	ffmpegthumbnailer -i "$1" -o "$CACHE" -s 0
	chafa -f sixel -s "$2x$3" --animate false "$CACHE"
	rm "$CACHE"
	;;
  *)
	bat --color=always --style=plain --pager=never "$1"
        ;;
esac
