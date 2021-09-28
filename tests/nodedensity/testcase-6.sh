#!/usr/bin/env bash
# Node Density Enhanced Testing
# Test Case 6 - Adjust number of exec probes

nodes=$(oc get no -l jetlag=true --no-headers | wc -l)

mkdir -p ../logs
sleep_period=120

gohttp_env_vars="-e LISTEN_DELAY_SECONDS=0 LIVENESS_DELAY_SECONDS=0 READINESS_DELAY_SECONDS=0 RESPONSE_DELAY_MILLISECONDS=0 LIVENESS_SUCCESS_MAX=0 READINESS_SUCCESS_MAX=0"
measurement="-D 180"
csvfile="--csv-file tc6-$1-$(date -u +%Y%m%d-%H%M%S).csv"

# Debug/Test entire Run
# dryrun="--dry-run"
# measurement="--no-measurement-phase"
# sleep_period=1

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case 6 Start"
echo "****************************************************************************************************************************************"

# Adjust number of probes (10s) (none, startup, s+l, s+l+r)
# Adjust number of pods/node (100, 200, 300, 400, 500)
probe_setups=("--no-probes" "--startup-probe exec,0,10,1,12 --liveness-probe off --readiness-probe off" "--startup-probe exec,0,10,1,12 --liveness-probe exec,0,10,1,3 --readiness-probe off" "--startup-probe exec,0,10,1,12 --liveness-probe exec,0,10,1,3 --readiness-probe exec,0,10,1,3,1")
probe_csv_titles=("n" "s" "sl" "slr")
probe_titles=("no probes" "exec startup" "exec startup/liveness" "exec startup/liveness/readiness")
pods_per_node="100 200 300 400 500"
test_index=0
for (( index=0; index<${#probe_setups[@]}; index++)); do
    for node_pods in ${pods_per_node}; do
      total_pods=$((${nodes} * ${node_pods}))
      echo "$(date -u +%Y%m%d-%H%M%S) - Total Pods ${total_pods}, Probes: ${probe_setups[${index}]}"

      test_index=$((${test_index} + 1))
      echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.${test_index} - 1 namespace, 1 deploy, ${total_pods} pods, 1 container (gohttp), 1 service, ${probe_titles[$index]}, 0 configmaps, 0 secrets"
      logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-6.${test_index}.log"
      ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-1d-${total_pods}p-1c-${probe_csv_titles[$index]}" -n 1 -d 1 -p ${total_pods} -c 1 -l -m 0 --secrets 0 ${probe_setups[${index}]} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
      echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.${test_index} complete, sleeping ${sleep_period}"
      sleep ${sleep_period}
      echo "****************************************************************************************************************************************"

      test_index=$((${test_index} + 1))
      echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.${test_index} - 1 namespace, ${total_pods} deploys, 1 pod, 1 container (gohttp), 1 service, ${probe_titles[$index]}, 0 configmaps, 0 secrets"
      logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-6.${test_index}.log"
      ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-${total_pods}d-1p-1c-${probe_csv_titles[$index]}" -n 1 -d ${total_pods} -p 1 -c 1 -l -m 0 --secrets 0 ${probe_setups[${index}]} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
      echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.${test_index} complete, sleeping ${sleep_period}"
      sleep ${sleep_period}
      echo "****************************************************************************************************************************************"

      test_index=$((${test_index} + 1))
      echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.${test_index} - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container (gohttp), 1 service, ${probe_titles[$index]}, 0 configmaps, 0 secrets"
      logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-6.${test_index}.log"
      ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-${probe_csv_titles[$index]}" -n ${total_pods} -d 1 -p 1 -c 1 -l -m 0 --secrets 0 ${probe_setups[${index}]} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
      echo "$(date -u +%Y%m%d-%H%M%S) - node density 6.${test_index} complete, sleeping ${sleep_period}"
      sleep ${sleep_period}
      echo "****************************************************************************************************************************************"

    done
done

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case 6 Complete"
