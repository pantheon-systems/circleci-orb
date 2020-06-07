#!/bin/bash

export EXISTING_ENVIRONMENTS=$(cat env-list.txt)


export TERMINUS_ENV=ci-123
echo "Testing ${TERMINUS_ENV}"

export OUTPUT_TO_CHECK=$(./deletions.sh $TERMINUS_ENV)

echo "${OUTPUT_TO_CHECK}"

./contains-check.sh "${OUTPUT_TO_CHECK}" "May need to delete old ci- environments to make room for this one"
./contains-check.sh "${OUTPUT_TO_CHECK}" "Getting list of all environments"
./contains-check.sh "${OUTPUT_TO_CHECK}" "checking if current environment is in list of existing environments"
./contains-check.sh "${OUTPUT_TO_CHECK}" "TERMINUS_ENV found in the list of environments"



export TERMINUS_ENV=ci-124
echo "Testing ${TERMINUS_ENV}"

export OUTPUT_TO_CHECK=$(./deletions.sh $TERMINUS_ENV)

echo "${OUTPUT_TO_CHECK}"

./contains-check.sh "${OUTPUT_TO_CHECK}" "May need to delete old ci- environments to make room for this one"
./contains-check.sh "${OUTPUT_TO_CHECK}" "Getting list of all environments"
./contains-check.sh "${OUTPUT_TO_CHECK}" "checking if current environment is in list of existing environments"
./contains-check.sh "${OUTPUT_TO_CHECK}" "Running clean-up script to delete old environments"






