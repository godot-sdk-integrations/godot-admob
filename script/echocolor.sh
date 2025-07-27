#!/bin/bash

# Original Source:
# https://github.com/Gruppio/Echolor.git

# Michele Gruppioni 2015
# http://www.michelegruppioni.com

# For more info
# http://misc.flogisoft.com/bash/tip_colors_and_formatting


rainbowColor=-2
rainbowColorIndex=0
rainbowColors=( 196 208 226 118 46 48 51 33 21 93 201 198 )
numRainbowColors=${#rainbowColors[@]}

foreground=38
background=48





# $3 The text
# $2 Color Code [0 - 255]  
# $1 Foreground 0 / Background 1
function printColoredText {

	text=$1
	colorCode=$2

	if [[ $3 == 1 ]]
	then
		foregroundCode=$background
	else
		foregroundCode=$foreground
	fi

	if [[ $colorCode == -1 ]] 
	then
		printf "\033[0 m$text"
		return
	fi

	if [[ $colorCode == $rainbowColor ]]
	then
		for (( i=0 ; i < ${#text} ; i++ ))
		do 
			colorCode=${rainbowColors[$rainbowColorIndex]}
			rainbowColorIndex=$(($rainbowColorIndex +1))
			rainbowColorIndex=$(($rainbowColorIndex %$numRainbowColors))
			character=${text:i:1}
			printf "\033[${foregroundCode};5;${colorCode}m${character}\033[0m"
		done
		return
	fi

	printf "\033[${foregroundCode};5;${colorCode}m${text}\033[0m"
}

# Check if the $1 parameter is a number > 0 and <= $2
function isInRange {
	if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 0 -a "$1" -le $2 ] && [ $# == 2 ]
	then
		echo $((1))
	else
		echo $((0))
	fi
}

# $1 = Red Component   [0 - 5]
# $2 = Green Component [0 - 5]
# $3 = Blue Component  [0 - 5]
function getColorCode {
	if [[ $(isInRange $1 5) == 1 && $(isInRange $2 5) == 1 && $(isInRange $3 5) == 1 && $# == 3 ]]
	then
		echo $((16 + (36 * $1) + (6 * $2) + $3))
	else
		echo $((-1))
	fi
}

function printUsage {
	$0 "\n"
	$0 --rainbow "===================================="
	$0 -W        " $0                                 "
	$0 --rainbow "   The most colorful echo command   "
	$0 --rainbow "===================================="

	$0 -Y "\n\nUsage:"
	$0 -W "$0 [[options] text]"
	$0 -W "Typical usage: " -G "$0 color1 text1 color2 text2 ..."

	$0 -Y "\n\nOptions:"
	$0 -C " -h|--help" 			-W " Print the correct usage" 
	$0 -C " -bk|--black" 		-W " Print the following parameters with a black color" -bk " example"
	$0 -C " -r|--red" 			-W " Print the following parameters with a red color" -r " example"
	$0 -C " -g|--green" 		-W " Print the following parameters with a green color" -g " example"
	$0 -C " -y|--yellow" 		-W " Print the following parameters with a yellow color" -y " example"
	$0 -C " -b|--blue" 			-W " Print the following parameters with a blue color" -b " example"
	$0 -C " -m|--magenta" 		-W " Print the following parameters with a magenta color" -m " example"
	$0 -C " -c|--cyan" 			-W " Print the following parameters with a cyan color" -c " example"
	$0 -C " -w|--white" 		-W " Print the following parameters with a white color" -w " example"
	$0 -C " -gy|--grey" 		-W " Print the following parameters with a grey color" -gy " example"
	$0 -C " -R|--Red"			-W " Print the following parameters with a bright red color" -R " example"
	$0 -C " -G|--Green"			-W " Print the following parameters with a bright green color" -G " example"
	$0 -C " -Y|--Yellow"		-W " Print the following parameters with a bright yellow color" -Y " example"
	$0 -C " -B|--Blue"			-W " Print the following parameters with a bright blue color" -B " example"
	$0 -C " -M|--Magenta"		-W " Print the following parameters with a bright magenta color" -M " example"
	$0 -C " -C|--Cyan"			-W " Print the following parameters with a bright cyan color" -C " example"
	$0 -C " -W|--White"			-W " Print the following parameters with a bright white color" -W " example"
	$0 -C " -Gy|--Gray"			-W " Print the following parameters with a bright grey color" -Gy " example"
	$0 -C " -h|--hex"			-W " Print the following parameters with a color from in a hex format.\n The hex color shall not start with the # but just 6 hex digits.\n example: " -G "$0 --hex F8E4B0 text \n"
	$0 -C " -rgb5"				-W " Print the following parameters with the specified R G B components.\n The R G B components must have a range between 0-5 and must be divided by a comma without spaces.\n example: " -G "$0 -rgb5 1,2,3 text \n"
	$0 -C " -rgb100"			-W " Print the following parameters with the specified R G B components.\n The R G B components must have a range between 0-100 and must be divided by a comma without spaces.\n example: " -G "$0 -rgb5 10,20,30 text \n"
	$0 -C " -rgb|-rgb255"		-W " Print the following parameters with the specified R G B components.\n The R G B components must have a range between 0-255 and must be divided by a comma without spaces.\n example: " -G "$0 -rgb5 100,200,255 text \n"
	$0 -C " -fg|--foreground"	-W " Color the foreground ( default )"
	$0 -C " -bg|--background"	-W " Color the background " -bg -R " example " -fg ""
	$0 -C " -n|-il|--in-line"	-W " With this option the command will not print the new line character after the execution\n"
	$0 -C " -ran|--random"		-W " Print the following parameters with a random color"
	$0 -C " -rb|--rainbow"		-W " Print the following parameters with a different color for each character following the classical Rainbow schema " -rb "example"
	$0 -C " -code|--color-code <code>" -W " Print the following parameters with the specified color code, the code must be a number between 0-255.\n"
	$0 -C " --get-color-code <r,g,b>" 	-W " Print the color code from the R G B components. The R G B components must have a range between 0-255 and must be divided by a comma without spaces.\n"



	$0 -Y "\n\nExamples:"
	$0 -il -G "$0 text" -W " will print: "
	$0 text
	
	$0 -il -G "$0 --Red RedText" -W " will print: "
	$0 --Red RedText
	
	$0 -il -G "$0 --Green GreenText" -W " will print: "
	$0 --Green GreenText
	
	$0 -il -G "$0 --Blue BlueText" -W " will print: "
	$0 --Blue BlueText
	
	$0 -il -G "$0 --Red \"RedText\" --Green \" GreenText\" --Blue \" BlueText\"" -W " will print: "
	$0 --Red RedText --Green " GreenText" --Blue " BlueText"

	$0 -il -G "$0 --rainbow \"Rainbow Colored Text\"" -W " will print: "
	$0 --rainbow "Rainbow Colored Text"
	
	$0 -il -G "$0 -rgb 100,200,30 \"Custom Color Text\"" -W " will print: "
	$0 -rgb 200,100,30 "Custom Color Text"

	$0 -il -G "$0 --hex FF88ee \"Color From Hex\"" -W " will print: "
	$0 --hex FF88ee "Color From Hex"
	
	$0 -il -G "$0 -B G -R o -Y o -B g -G l -R e" -W " will print: "
	$0 -B G -R o -Y o -B g -G l -R e

	$0 -Y "\n\nInfo:"
	$0 -Gy "Original Sources at: https://github.com/Gruppio/Echolor.git"
	$0 -Gy "Created by Gruppio 2015"
	
	$0 "\n"
	exit -1
}

# Main
color=-1
colorBackground=0
inline=0

while (( "$#" ))
do
	case $1 in
		-h|--help)			printUsage ;;
	    -bk|--black)		color=0 ;;
		-r|--red) 			color=1 ;;
		-g|--green) 		color=2 ;;
		-y|--yellow) 		color=3 ;;
		-b|--blue) 			color=4 ;;
		-m|--magenta) 		color=5 ;;
		-c|--cyan) 			color=6 ;;
		-w|--white) 		color=7 ;;
		-Gy|--Grey) 		color=8 ;;
		-R|--Red) 			color=9 ;;
		-G|--Green) 		color=10 ;;
		-Y|--Yellow) 		color=11 ;;
		-B|--Blue) 			color=12 ;;
		-M|--Magenta) 		color=13 ;;
		-C|--Cyan) 			color=14 ;;
		-W|--White) 		color=15 ;;
		-gy|--gray) 		color=16 ;;
		-fg|--foreground)	colorBackground=0 ;;
		-bg|--background) 	colorBackground=1 ;;
		-il|--in-line)		inline=1 ;;
		-ran|--random)		color=$(($RANDOM %255)) ;;
		-rb|--rainbow)		
			color=$rainbowColor
			rainbowColorIndex=0
		;;
		-code|--color-code) 
			color=$2
			shift
		;;
		--get-color-code) 
			IFS=, read r g b <<< "$2"
			if [[ $r && $g && $b ]]
			then
				r=$(($r/51))
				g=$(($g/51))
				b=$(($b/51))
				getColorCode $r $g $b
				exit 0
			else
				printUsage
			fi
		;;
		-rgb5)
			IFS=, read r g b <<< "$2"
			if [[ $r && $g && $b ]]
			then
				color=$(getColorCode $r $g $b)
				shift
			else
				printUsage
			fi
		;;
		-rgb100)
			IFS=, read r g b <<< "$2"
			if [[ $r && $g && $b ]]
			then
				r=$(($r/20))
				g=$(($g/20))
				b=$(($b/20))
				color=$(getColorCode $r $g $b)
				shift
			else
				printUsage
			fi
		;;
		-rgb|-rgb255)
			IFS=, read r g b <<< "$2"
			if [[ $r && $g && $b ]]
			then
				r=$(($r/51))
				g=$(($g/51))
				b=$(($b/51))
				color=$(getColorCode $r $g $b)
				shift
			else
				printUsage
			fi
		;;
		-h|--hex)
			if [[ $# > 1 && $2 =~ ^[0-9A-Fa-f]{6}$ ]]
			then
				hex=$2
				r=$(printf "%d\n" 0x${hex:0:2}) 
				g=$(printf "%d\n" 0x${hex:2:2})
				b=$(printf "%d\n" 0x${hex:4:2})
				r=$(($r/51))
				g=$(($g/51))
				b=$(($b/51))
				color=$(getColorCode $r $g $b)
				shift
			else
				printUsage
			fi
		;;
		# print the text
	    *) 
			text=$1
			printColoredText "$text" $color $colorBackground 
		;;
	esac
	shift
done

if [[ $inline == 0 ]]
then
	printf "\n"
fi

exit 0
