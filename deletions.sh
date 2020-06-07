#!/bin/bash

export TERMINUS_ENV=${1}


#echo $TERMINUS_ENV

if [[ $TERMINUS_ENV = ci-* || $TERMINUS_ENV = pr-*   ]]
then
	echo "TERMINUS_ENV Starts with ci-"
    echo "May need to delete old ci- or pr- environments to make room for this one"

    echo "Getting list of all environments"
    export ENV_LIST=$(cat ./env-list.txt)
    echo "checking if current environment is in list of existing environments"
    if [[ $(echo "${ENV_LIST}" | grep -x ${TERMINUS_ENV})  ]]
    then
        echo "TERMINUS_ENV found in the list of environments"
        exit 0
    else
        echo "TERMINUS_ENV not found in the list of environments."
        echo "Running clean-up script to delete old pr- environments"
        ######### delete old pr- environments here




        if [[ $TERMINUS_ENV = ci-*  ]]
        then
            echo "Running clean-up script to delete old ci- environments"
            ######## delete old ci- envs here
        else
            echo "skipping deletion of ci- envs"
        fi

    fi

    
      




else
	echo "No match"
fi