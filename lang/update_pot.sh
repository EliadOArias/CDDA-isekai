#!/bin/sh

if [ ! -d lang/po ]
then
    if [ -d ../lang/po ]
    then
        cd ..
    else
        echo "Error: Could not find lang/po subdirectory."
        exit 1
    fi
fi

echo "> Extracting strings from JSON"
if ! lang/extract_json_strings.py \
        -i . \
        -r lang/po/base.pot
then
    echo "Error in extracting strings from JSON. Aborting."
    exit 1
fi

echo "> Unification of translation template"
msguniq -o lang/po/cataclysm-dda.pot lang/po/base.pot
if [ ! -f lang/po/cataclysm-dda.pot ]; then
    echo "Error in merging translation templates. Aborting."
    exit 1
fi
sed -i "/^#\. #-#-#-#-#  [a-zA-Z0-9(). -]*#-#-#-#-#$/d" lang/po/cataclysm-dda.pot

# convert line endings to unix
os="$(uname -s)"
if (! [ "${os##CYGWIN*}" ]) || (! [ "${os##MINGW*}" ])
then
    echo "> Converting line endings to Unix"
    if ! sed -i -e 's/\r$//' lang/po/cataclysm-dda.pot
    then
        echo "Line ending conversion failed. Aborting."
        exit 1
    fi
fi

# Final compilation check
echo "> Testing to compile translation template"
if ! msgfmt -c -o /dev/null lang/po/cataclysm-dda.pot
then
    echo "Translation template cannot be compiled. Aborting."
    exit 1
fi

# Check for broken Unicode symbols
echo "> Checking for wrong Unicode symbols"
if ! lang/unicode_check.py lang/po/cataclysm-dda.pot
then
    echo "Updated pot file contain broken Unicode symbols. Aborting."
    exit 1
fi

echo "ALL DONE!"
