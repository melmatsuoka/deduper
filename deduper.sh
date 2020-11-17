#!/usr/bin/env bash
#
# deduper
#
# Author: Mel Matsuoka <mel@montaj9.com>
#    
# Removes repeated frames in source video file, and re-encodes to ProRes HQ.
#
# It will assume bt709 colorspace/trc/primaries by default, but if there is a color-shift in the 
# converted file, you can override this so it matches (sometimes an HD source file
# will have 601 primaries/transfer characteristics, so you need to preserve the 601
# in the converted file)
#
# DEPENDENCIES:
#       - MediaInfo
#       - ffmpeg (with GPL libraries enabled)
#
# TODO: 
#       - preserve first frame timecode
#       - auto-detect color shifts 
#       - preserve/transfer as much original metadata as possible into converted file
#       - transfer in sync audio 

VERSION="0.2"
NUMARGS=$#
USAGE="deduper v${VERSION} - USAGE: deduper <SOURCEFILE> [601|709]\n "

if [ $NUMARGS == "0" ]
    then
        echo -e "$USAGE"
        echo -e "Removes repeated frames in source video file, and re-encodes to ProRes HQ.\n\nIt will assume bt709 colorspace/trc/primaries by default, but if there is a color-shift\nin the converted file, you can override this so it matches (sometimes an HD source file\nwill have 601 primaries/transfer characteristics, so you need to preserve the 601 in\nthe converted file)\n"
        exit
    else

        sourcefile="${1}"
        colorspace="${2}"

            case ${colorspace} in
                601) 
                    color_primaries=6
                    color_trc=6
                    colorspace=6
                    ;;
                709) 
                    color_primaries=1
                    color_trc=1
                    colorspace=1
                    ;;
                *) 
                    color_primaries=1
                    color_trc=1
                    colorspace=1
                    ;;
            esac

    # get first-frame timecode

    local TIMECODE=$(mediainfo --Inform="Other;%TimeCode_FirstFrame%" "${1}")

    ffmpeg -i "${1}" \
    -vf mpdecimate,setpts=N/FRAME_RATE/TB \
    -timecode "${TIMECODE}" \
    -vcodec prores_ks \
    -vprofile hq \
    -metadata:s encoder="Apple ProRes 422 (HQ)" \
    -vendor apl0 \
    -pix_fmt yuv422p10le \
    -movflags +write_colr \
    -color_primaries ${color_primaries} \
    -color_trc ${color_trc} \
    -colorspace ${colorspace} \
    "${1%.*}-deduped.mov"

    echo "DONE."
fi
