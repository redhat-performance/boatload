#!/usr/bin/env bash
# Node Density Enhanced Testing for SNO
# Test Case 5 - Validate Max-pods with http probes
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
tc_num=6

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

probe_type="http"
probes=()
probes+=("--startup-probe ${probe_type},0,10,1,12 --liveness-probe off --readiness-probe off")
probes+=("--startup-probe ${probe_type},0,5,1,12 --liveness-probe off --readiness-probe off")
probes+=("--startup-probe ${probe_type},0,1,1,12 --liveness-probe off --readiness-probe off")
probes+=("--startup-probe ${probe_type},0,10,1,12 --liveness-probe ${probe_type},0,10,1,12 --readiness-probe off")
probes+=("--startup-probe ${probe_type},0,5,1,12 --liveness-probe ${probe_type},0,5,1,12 --readiness-probe off")
probes+=("--startup-probe ${probe_type},0,1,1,12 --liveness-probe ${probe_type},0,1,1,12 --readiness-probe off")
probes+=("--startup-probe ${probe_type},0,10,1,12 --liveness-probe ${probe_type},0,10,1,12 --readiness-probe ${probe_type},0,10,1,12")
probes+=("--startup-probe ${probe_type},0,5,1,12 --liveness-probe ${probe_type},0,5,1,12 --readiness-probe ${probe_type},0,5,1,12")
probes+=("--startup-probe ${probe_type},0,1,1,12 --liveness-probe ${probe_type},0,1,1,12 --readiness-probe ${probe_type},0,1,1,12")

probes_csv_titles=()
probes_csv_titles+=("${probe_type}-s10-l0-r0")
probes_csv_titles+=("${probe_type}-s5-l0-r0")
probes_csv_titles+=("${probe_type}-s1-l0-r0")
probes_csv_titles+=("${probe_type}-s10-l10-r0")
probes_csv_titles+=("${probe_type}-s5-l5-r0")
probes_csv_titles+=("${probe_type}-s1-l1-r0")
probes_csv_titles+=("${probe_type}-s10-l10-r10")
probes_csv_titles+=("${probe_type}-s5-l5-r5")
probes_csv_titles+=("${probe_type}-s1-l1-r1")

for (( index=0; index<${#probes[@]}; index++)); do
  for iteration in `seq 1 ${iterations}`; do
    test_index=$((${test_index} + 1))
    echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container, gohttp image, 1 service, 1 route, ${probes[$index]}, no configmaps, no secrets, no resources set"
    logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
    ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${probes_csv_titles[$index]}-${iteration}" -n ${total_pods} -d 1 -p 1 -c 1 -l -r  ${probes[$index]} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
    echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
    sleep ${sleep_period}
    echo "****************************************************************************************************************************************"
  done
done

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case ${tc_num} Complete"
