#!/bin/bash
# Usage: convert-html-to-md <path-to-html2text.py> <file>[...]
# Convert the specified HTML files into Markdown text-format equivalents
# in the current working directory. The file extension will be .md.txt.
# Requires the html2text.py Python script by Aaron Swartz to convert
# from HTML to Markdown text [www.aaronsw.com/2002/html2text/].
html2text="${1}"
shift

while [ -n "${1}" ] ; do
    # Use the contents of the title element for the filename. In case
    # the title element spans multiple lines, the entire file is first
    # converted to a single line before the sed pattern is applied. Any
    # "unsafe" characters are then replaced with hyphens to produce a
    # valid filename.
    title=$(cat "${1}" | \
            tr -d '\n\r' | \
            sed -nre 's/^.*<title>(.*?)<\/title>.*$/\1\n/ip' | \
            tr "\`~\!@#$%^&*()+={}|[]\\:;\"\'<>?,/ \t" '[-*]')

    # If there's no title, then just use the original filename.
    if [ -z "${title}" ] ; then
        title=$(basename "${1}" .html)
    fi

    # Convert the HTML to Markdown.
    cat "${1}" | python "${html2text}" > "${title}.markdown"
    shift
done