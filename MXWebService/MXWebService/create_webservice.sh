#!/bin/sh

#  create_webservice.sh
#  MXEngine
#
#  Created by lly on 16/6/13.
#  Copyright © 2016年 lly. All rights reserved.

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

protoRegex="@protocol ([a-zA-Z0-9]*) <MXWebService>"

find "${SRCROOT}" -type f -name "*.h" -print0 | while IFS= read -r -d '' file; do
contents=$(<"${file}")

if [[ ${contents} =~ $protoRegex ]]; then
echo "${file} matches"
echo "Protocol name: ${BASH_REMATCH[1]}"

perl "${DIR}/parse_webservice.pl" "${file}" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
done

echo "Web service generation finished"