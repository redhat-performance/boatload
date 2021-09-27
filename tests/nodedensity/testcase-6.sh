#!/usr/bin/env bash
# Node Density Enhanced Testing
# Test Case 6 - Route Test

nodes=$(oc get no -l jetlag=true --no-headers | wc -l)
node_pods=5
total_pods=$((${nodes} * ${node_pods}))

mkdir -p ../logs
sleep_period=120

gohttp_env_vars="-e LISTEN_DELAY_SECONDS=0 LIVENESS_DELAY_SECONDS=0 READINESS_DELAY_SECONDS=0 RESPONSE_DELAY_MILLISECONDS=0 LIVENESS_SUCCESS_MAX=0 READINESS_SUCCESS_MAX=0"
measurement="-D 180"
csvfile="--csv-file tc6-$1-$(date -u +%Y%m%d-%H%M%S).csv"

# Debug/Test entire Run
# dryrun="--dry-run"
measurement="--no-measurement-phase --no-cleanup-phase"
# sleep_period=1

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case 6 Start"
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * 500pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"

probes="--startup-probe http,0,10,1,12 --liveness-probe http,0,10,1,3 --readiness-probe http,0,10,1,3,1"

echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.1 - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container (gohttp), 1 service, 1 route, 10s period probes, 0 configmaps, 0 secrets"
logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-6.1.log"
../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-gohttp" -n ${total_pods} -d 1 -p 1 -c 1 -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.1 complete, sleeping ${sleep_period}"
# sleep ${sleep_period}

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case 6 Complete"
