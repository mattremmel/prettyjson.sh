#!/bin/bash

# ------------------------------------------------------------------
#  Author: Matthew Remmel (matt.remmel@gmail.com)
#  Title: PrettyJSON
#
#  Description: PrettyJSON is a script that reads JSON from standard
#               in and pretty prints it to standard out.
#
#  Return:      A 1 is returned if there is a problem parsing the
#               JSON. A 0 is returned otherwise.
#
#  Dependency:  cat, grep
# ------------------------------------------------------------------

# --- Version and Usage ---
DESCRIPTION="Description: Reads JSON from standard in and prints it to standard out"
VERSION=0.1.1
USAGE="Usage: {json} | prettyjson [option]

Options:
-h, --help       Show help and usage information
-v, --version    Show version information
-i, --indent     Specify the number of added spaces per indent level"

# --- Dependecy Check ---
command -v cat >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'cat' not installed. Exiting."; exit 1; }
command -v grep >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'grep' not installed. Exiting."; exit 1; }
command -v seq >/dev/null 2>&1 || { echo >&2 "[ERROR] Dependency 'seq' not installed. Exiting."; exit 1; }

# --- Arguments ---
INDCNT=3

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
	-h|--help)
	    echo "$DESCRIPTION"
	    echo
	    echo "$USAGE"
	    echo
	    exit 0;;
	-v|--version)
	    echo "Version: $VERSION"
	    exit 0;;
  	-i|--indent)
      	    INDCNT=$2
            shift;;
	*)
	    echo "Unknown argument: $key"
	    exit 1;;
    esac

    shift
done

# --- Main Body ---
INPUT=$(cat "-" | grep -o .)
INDENT=0
BUFF=""
FORMJSON=""

PRINT_BUFF() {
  OUTPUT=""

  # Avoid adding newline to beginning of output
  if [ "$FORMJSON" != "" ]; then
    OUTPUT="$OUTPUT\n"
  fi

  # Add Tab Indent
  if [ $INDENT -ne 0 ]; then
    for i in $(seq 1 $((INDENT*INDCNT))); do
      OUTPUT="$OUTPUT "
    done
  fi

  # Update output and clear buffer
  OUTPUT="$OUTPUT$BUFF"
  FORMJSON="$FORMJSON$OUTPUT"
  BUFF=""
}

for c in $INPUT; do

  # Opening brace
  if [ $c = "{" ]; then
    BUFF="$BUFF$c"
    PRINT_BUFF
    INDENT=$((INDENT+1))

  # Closing brace
  elif [ $c = "}" ]; then
    PRINT_BUFF
    INDENT=$((INDENT-1))
    BUFF="$BUFF$c"

  # Colon
  elif [ $c = ":" ]; then
    BUFF="$BUFF $c "

  # Opening bracket
  elif [ $c = "[" ]; then
    BUFF="$BUFF$c"
    PRINT_BUFF
    INDENT=$((INDENT+1))

  # Closing bracket
  elif [ $c = "]" ]; then
    PRINT_BUFF
    INDENT=$((INDENT-1))
    BUFF="$BUFF$c"

  # Comma
  elif [ $c = "," ]; then
    BUFF="$BUFF$c"
    PRINT_BUFF

  # Non Whitespace
  elif [ $c != " " ] && [ $c != "\n" ] && [ $c != "\t" ]; then
    BUFF="$BUFF$c"
  fi

done

# Print remaining buffer
PRINT_BUFF

# Write output to standard out
echo -e "$FORMJSON"

exit 0
