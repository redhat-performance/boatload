#!/usr/bin/env bash
set -e
set -o pipefail

# 168 pods/namespaces
# 218 pods/namespaces
# 268 pods/namespaces
# 318 pods/namespaces
# 368 pods/namespaces
# 418 pods/namespaces

mkdir -p ../logs
mkdir -p ../results

version=$(oc version -o json | jq -r '.openshiftVersion')

sdn_pods=$(oc get po -n openshift-sdn --no-headers | wc -l)
network="ovn"
if [[ $sdn_pods -gt 0 ]]; then
  network="sdn"
fi

nodes=$(oc get no -l jetlag=true --no-headers | wc -l)

gohttp_env_vars="-e LISTEN_DELAY_SECONDS=0 LIVENESS_DELAY_SECONDS=0 READINESS_DELAY_SECONDS=0 RESPONSE_DELAY_MILLISECONDS=0 LIVENESS_SUCCESS_MAX=0 READINESS_SUCCESS_MAX=0"
measurement="-D 180"
metrics="--metrics nodeReadyStatus nodeCoresUsed nodeMemoryConsumed kubeletCoresUsed kubeletMemory crioCoresUsed crioMemory rxNetworkBytes txNetworkBytes nodeDiskWrittenBytes nodeDiskReadBytes nodeCPU"

sleep_period=120
iterations=3

# Debug/Test entire Run
# dryrun="--dry-run"
# measurement="--no-measurement-phase"
# sleep_period=1
# iterations=1

tc_num=1
test_index=0
csv_suffix="${version}-${network}-sno${nodes}"
csv_ts=$(date -u +%Y%m%d-%H%M%S)
csvfile="--csv-results-file ../results/results-ramp-${csv_suffix}-${csv_ts}.csv --csv-metrics-file ../results/metrics-ramp-${csv_suffix}-${csv_ts}.csv"
echo "$(date -u +%Y%m%d-%H%M%S) - SNO Ramp Node Density Test ${tc_num} Start"
node_pods=168
total_pods=168
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, ${containers[$arg_index]} containers, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${iteration}" ${metrics} -n ${total_pods} -d 1 -p 1 -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

tc_num=2
test_index=0
echo "$(date -u +%Y%m%d-%H%M%S) - SNO Ramp Node Density Test ${tc_num} Start"
node_pods=218
total_pods=218
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, ${containers[$arg_index]} containers, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${iteration}" ${metrics} -n ${total_pods} -d 1 -p 1 -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

tc_num=3
test_index=0
echo "$(date -u +%Y%m%d-%H%M%S) - SNO Ramp Node Density Test ${tc_num} Start"
node_pods=268
total_pods=268
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, ${containers[$arg_index]} containers, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${iteration}" ${metrics} -n ${total_pods} -d 1 -p 1 -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

tc_num=4
test_index=0
echo "$(date -u +%Y%m%d-%H%M%S) - SNO Ramp Node Density Test ${tc_num} Start"
node_pods=318
total_pods=318
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, ${containers[$arg_index]} containers, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${iteration}" ${metrics} -n ${total_pods} -d 1 -p 1 -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

tc_num=5
test_index=0
echo "$(date -u +%Y%m%d-%H%M%S) - SNO Ramp Node Density Test ${tc_num} Start"
node_pods=368
total_pods=368
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, ${containers[$arg_index]} containers, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${iteration}" ${metrics} -n ${total_pods} -d 1 -p 1 -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

tc_num=6
test_index=0
echo "$(date -u +%Y%m%d-%H%M%S) - SNO Ramp Node Density Test ${tc_num} Start"
node_pods=418
total_pods=418
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, ${containers[$arg_index]} containers, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${iteration}" ${metrics} -n ${total_pods} -d 1 -p 1 -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done
