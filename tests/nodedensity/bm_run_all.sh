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

# time ./testcase-1.sh ${version}-${network}-bm${nodes} 250 1 | tee ${version}-${network}-bm${nodes}-tc1.log
# sleep ${sleep_time}
# Test case 2 is a variation of testcase 1
time ./testcase-1.sh ${version}-${network}-bm${nodes} 500 2 | tee ${version}-${network}-bm${nodes}-tc2.log
sleep ${sleep_time}
time ./testcase-3.sh ${version}-${network}-bm${nodes} 500 | tee ${version}-${network}-bm${nodes}-tc3.log
sleep ${sleep_time}
time ./testcase-4.sh ${version}-${network}-bm${nodes} 500 | tee ${version}-${network}-bm${nodes}-tc4.log
sleep ${sleep_time}
time ./testcase-5.sh ${version}-${network}-bm${nodes} 500 | tee ${version}-${network}-bm${nodes}-tc5.log
sleep ${sleep_time}
time ./testcase-6.sh ${version}-${network}-bm${nodes} 500 | tee ${version}-${network}-bm${nodes}-tc6.log
sleep ${sleep_time}
time ./testcase-7.sh ${version}-${network}-bm${nodes} 500 | tee ${version}-${network}-bm${nodes}-tc7.log
sleep ${sleep_time}
