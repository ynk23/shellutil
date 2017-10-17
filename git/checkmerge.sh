#!/bin/bash

me=$1;
if [[ -z $me ]]; then
        echo "Usage : $(basename $0) check-branch dir";
        exit 1;
fi
dir=$2
if [[ -z $dir ]]; then
        echo "Usage : $(basename $0) check-branch dir";
        exit 1;
fi

declare merged="";
declare nomerged="";

cd $dir;
for branch in $(git branch -l | sed 's/\*//');
do
        branch=${branch#\* };
        if [[ $branch =~ $me ]]; then
                continue;
        else
                git checkout $branch;
                for mergedbranch in $(git branch --merged);
                do
                        if [[ $mergedbranch =~ $me ]]; then
                                merged="$merged\n$branch";
                                continue;
                        fi
                done
                for nomergedbranch in $(git branch --no-merged);
                do
                        if [[ $nomergedbranch =~ $me ]]; then
                                nomerged="$nomerged\n$branch";
                                continue;
                        fi
                done
        fi
done
cd -;

echo "[finish]";
echo -e "### merged ###$merged";
echo -e "### no merged ###$nomerged";
