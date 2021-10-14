#!/usr/bin/env bash
# Node Density Enhanced Testing for SNO
# Test Case 8 - Max-pods with 2 containers, configmaps, secrets, Guaranteed resources and http probes
set -e
set -o pipefail

csv_suffix=$1

nodes=$(oc get no -l jetlag=true --no-headers | wc -l)
node_pods=$2
total_pods=$((${nodes} * ${node_pods}))

mkdir -p ../logs
mkdir -p ../results
sleep_period=120
iterations=3
tc_num=8

gohttp_env_vars="-e LISTEN_DELAY_SECONDS=0 LIVENESS_DELAY_SECONDS=0 READINESS_DELAY_SECONDS=0 RESPONSE_DELAY_MILLISECONDS=0 LIVENESS_SUCCESS_MAX=0 READINESS_SUCCESS_MAX=0"
measurement="-D 180"
csv_ts=$(date -u +%Y%m%d-%H%M%S)
csvfile="--csv-results-file ../results/results-tc${tc_num}-${csv_suffix}-${csv_ts}.csv --csv-metrics-file ../results/metrics-tc${tc_num}-${csv_suffix}-${csv_ts}.csv"

# Debug/Test entire Run
# dryrun="--dry-run"
# measurement="--no-measurement-phase"
# sleep_period=1
# iterations=1
# total_pods=$2

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case ${tc_num} Start"
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
test_index=0

configmaps_secrets=" -m 8 --secrets 8 "
probes=" --startup-probe http,0,1,1,12 --liveness-probe http,0,1,1,3 --readiness-probe http,0,1,1,3,1 "
resources=" --cpu-requests 50 --memory-requests 100 --cpu-limits 50 --memory-limits 100 "

for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, 2 containers, gohttp image, 1 service, 1 route, http probes, 8 configmaps, 8 secrets, guaranteed resources"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-2c-${iteration}" -n ${total_pods} -d 1 -p 1 -c 2 -l -r ${configmaps_secrets} ${probes} ${resources} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

measurement=" -D 7200 "

test_index=$((${test_index} + 1))
echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - long test - ${total_pods} namespaces, 1 deploy, 1 pod, 2 containers, gohttp image, 1 service, 1 route, http probes, 8 configmaps, 8 secrets, guaranteed resources"
logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-2c-${iteration}" -n ${total_pods} -d 1 -p 1 -c 2 -l -r ${configmaps_secrets} ${probes} ${resources} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - long test complete"
echo "****************************************************************************************************************************************"


echo "$(date -u +%Y%m%d-%H%M%S) - Test Case ${tc_num} Complete"
