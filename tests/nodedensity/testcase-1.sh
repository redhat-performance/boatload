#!/usr/bin/env bash
# Node Density Enhanced Testing for SNO
# Test Case 1 - Validate Max-pods with different container images, deployment hierarchy, and container counts
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
tc_num=$3

gohttp_env_vars="-e LISTEN_DELAY_SECONDS=0 LIVENESS_DELAY_SECONDS=0 READINESS_DELAY_SECONDS=0 RESPONSE_DELAY_MILLISECONDS=0 LIVENESS_SUCCESS_MAX=0 READINESS_SUCCESS_MAX=0"
measurement="-D 180"
csv_ts=$(date -u +%Y%m%d-%H%M%S)
csvfile="--csv-results-file ../results/results-tc${tc_num}-${csv_suffix}-${csv_ts}.csv --csv-metrics-file ../results/metrics-tc${tc_num}-${csv_suffix}-${csv_ts}.csv"

# Debug/Test entire Run
# dryrun="--dry-run"
# measurement="--no-measurement-phase"
# sleep_period=1
# iterations=1

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case ${tc_num} Start"
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"
test_index=0

# Pod replicas scaled
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - 1 namespace, 1 deploy, ${total_pods} pods, 1 container, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-1d-${total_pods}p-1c-${iteration}" -n 1 -d 1 -p ${total_pods} -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done


# Deploys scaled
for iteration in `seq 1 ${iterations}`; do
  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - 1 namespace, ${total_pods} deploys, 1 pod, 1 container, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-${total_pods}d-1p-1c-${iteration}" -n 1 -d ${total_pods} -p 1 -c 1 -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

# Namespaces scaled (additional images as well)
images=("quay.io/redhat-performance/test-gohttp-probe:v0.0.2" "gcr.io/google_containers/pause-amd64:3.0" "quay.io/akrzos/hello-kubernetes:20210907")
tc_titles=("gohttp" "pause" "hello-kubernetes")
csv_titles=("gohttp" "pause" "hello")
for (( arg_index=0; arg_index<${#images[@]}; arg_index++)); do
  for iteration in `seq 1 ${iterations}`; do
    test_index=$((${test_index} + 1))
    echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container, ${tc_titles[$arg_index]} image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
    logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
    ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${csv_titles[$arg_index]}-${iteration}" -n ${total_pods} -d 1 -p 1 -c 1 -l -r --no-probes -i ${images[$arg_index]} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
    echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
    sleep ${sleep_period}
    echo "****************************************************************************************************************************************"
  done
done

# Scale container counts
if [[ ${tc_num} == "2" ]];
then
  containers=("2" "3")
else
  containers=("2" "3" "4")
fi
for (( arg_index=0; arg_index<${#containers[@]}; arg_index++)); do
  for iteration in `seq 1 ${iterations}`; do
    test_index=$((${test_index} + 1))
    echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} - ${total_pods} namespaces, 1 deploy, 1 pod, ${containers[$arg_index]} containers, gohttp image, 1 service, 1 route, no probes, no configmaps, no secrets, no resources set"
    logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-${tc_num}.${test_index}.log"
    ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-${containers[$arg_index]}c-${iteration}" -n ${total_pods} -d 1 -p 1 -c ${containers[$arg_index]} -l -r --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
    echo "$(date -u +%Y%m%d-%H%M%S) - node density ${tc_num}.${test_index} - ${iteration}/${iterations} complete, sleeping ${sleep_period}"
    sleep ${sleep_period}
    echo "****************************************************************************************************************************************"
  done
done

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case ${tc_num} Complete"
