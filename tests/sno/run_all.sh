#!/usr/bin/env bash

version=$(oc version -o json | jq -r '.openshiftVersion')

sdn_pods=$(oc get po -n openshift-sdn --no-headers | wc -l)
network="ovn"
if [[ $sdn_pods -gt 0 ]]; then
  network="sdn"
fi

sleep_time=300
# sleep_time=1

time ./testcase-1.sh ${version}-${network}-168 168 1 | tee ${version}-${network}-tc1.log
sleep ${sleep_time}
# Test case 2 is a variation of testcase 1
time ./testcase-1.sh ${version}-${network}-418 418 2 | tee ${version}-${network}-tc2.log
sleep ${sleep_time}
time ./testcase-3.sh ${version}-${network} 418 | tee ${version}-${network}-tc3.log
sleep ${sleep_time}
time ./testcase-4.sh ${version}-${network} 418 | tee ${version}-${network}-tc4.log
sleep ${sleep_time}
time ./testcase-5.sh ${version}-${network} 418 | tee ${version}-${network}-tc5.log
sleep ${sleep_time}
time ./testcase-6.sh ${version}-${network} 418 | tee ${version}-${network}-tc6.log
sleep ${sleep_time}
time ./testcase-7.sh ${version}-${network} 418 | tee ${version}-${network}-tc7.log
sleep ${sleep_time}
