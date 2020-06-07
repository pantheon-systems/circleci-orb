#!/bin/bash
if [[ ${1} == *"${2}"* ]]; then
  echo "FOUND!"
  echo "${2}"
  exit 0;
fi

  echo "NOT FOUND!"
  echo "${2}"
exit 1;
