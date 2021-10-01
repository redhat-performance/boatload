#!/usr/bin/env bash

version=$(oc version -o json | jq -r '.openshiftVersion')

sdn_pods=$(oc get po -n openshift-sdn --no-headers | wc -l)
network="ovn"
if [[ $sdn_pods -gt 0 ]]; then
  network="sdn"
fi

time ./testcase-1.sh ${version}-${network}-168 168 | tee ${version}-${network}-tc1.log
sleep 300
time ./testcase-1.sh ${version}-${network}-418 418 | tee ${version}-${network}-tc1.log
sleep 300
