#!/usr/bin/env bash
set -xe
set -o pipefail

version=$(oc version -o json | jq -r '.openshiftVersion')

sdn_pods=$(oc get po -n openshift-sdn --no-headers | wc -l)
network="ovn"
if [[ $sdn_pods -gt 0 ]]; then
  network="sdn"
fi

nodes=$(oc get no -l jetlag=true --no-headers | wc -l)

sleep_time=300
# sleep_time=1

time ./testcase-1.sh ${version}-${network}-sno${nodes}-168 168 1 | tee ${version}-${network}-sno${nodes}-tc1.log
sleep ${sleep_time}
# Test case 2 is a variation of testcase 1
time ./testcase-1.sh ${version}-${network}-sno${nodes}-418 418 2 | tee ${version}-${network}-sno${nodes}-tc2.log
sleep ${sleep_time}
time ./testcase-3.sh ${version}-${network}-sno${nodes} 418 | tee ${version}-${network}-sno${nodes}-tc3.log
sleep ${sleep_time}
time ./testcase-4.sh ${version}-${network}-sno${nodes} 418 | tee ${version}-${network}-sno${nodes}-tc4.log
sleep ${sleep_time}
time ./testcase-5.sh ${version}-${network}-sno${nodes} 418 | tee ${version}-${network}-sno${nodes}-tc5.log
sleep ${sleep_time}
time ./testcase-6.sh ${version}-${network}-sno${nodes} 418 | tee ${version}-${network}-sno${nodes}-tc6.log
sleep ${sleep_time}
# Test case 7 is too difficult so lets keep it commented out for now
# time ./testcase-7.sh ${version}-${network}-sno${nodes} 418 | tee ${version}-${network}-sno${nodes}-tc7.log
# sleep ${sleep_time}
time ./testcase-8.sh ${version}-${network}-sno${nodes} 418 | tee ${version}-${network}-sno${nodes}-tc8.log
# sleep ${sleep_time}
