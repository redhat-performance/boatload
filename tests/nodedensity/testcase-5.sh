#!/usr/bin/env bash
# Node Density Enhanced Testing
# Test Case 5 - Adjust probe period (10s, 5s, 1s)

nodes=$(oc get no -l jetlag=true --no-headers | wc -l)
node_pods=500
total_pods=$((${nodes} * ${node_pods}))

mkdir -p ../logs
sleep_period=120

gohttp_env_vars="-e LISTEN_DELAY_SECONDS=0 LIVENESS_DELAY_SECONDS=0 READINESS_DELAY_SECONDS=0 RESPONSE_DELAY_MILLISECONDS=0 LIVENESS_SUCCESS_MAX=0 READINESS_SUCCESS_MAX=0"
measurement="-D 180"
csvfile="--csv-file tc5-$1-$(date -u +%Y%m%d-%H%M%S).csv"

# Debug/Test entire Run
# dryrun="--dry-run"
# measurement="--no-measurement-phase"
# sleep_period=1

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case 5 Start"
echo "$(date -u +%Y%m%d-%H%M%S) - Total Pod Count (Nodes * 500pods/node) :: ${nodes} * ${node_pods} = ${total_pods}"
echo "****************************************************************************************************************************************"

probe_periods="10 5 1"
test_index=0

# No Probes first
test_index=$((${test_index} + 1))
echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, 1 deploy, ${total_pods} pods, 1 container (gohttp), 1 service, no probes, 0 configmaps, 0 secrets"
logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-1d-${total_pods}p-1c-gohttp-no-probes" -n 1 -d 1 -p ${total_pods} -c 1 -l -m 0 --secrets 0 --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
sleep ${sleep_period}
echo "****************************************************************************************************************************************"

test_index=$((${test_index} + 1))
echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, ${total_pods} deploys, 1 pod, 1 container (gohttp), 1 service, no probes, 0 configmaps, 0 secrets"
logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-${total_pods}d-1p-1c-gohttp-no-probes" -n 1 -d ${total_pods} -p 1 -c 1 -l -m 0 --secrets 0 --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
sleep ${sleep_period}
echo "****************************************************************************************************************************************"

test_index=$((${test_index} + 1))
echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container (gohttp), 1 service, no probes, 0 configmaps, 0 secrets"
logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-gohttp-no-probes" -n ${total_pods} -d 1 -p 1 -c 1 -l -m 0 --secrets 0 --no-probes ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
sleep ${sleep_period}
echo "****************************************************************************************************************************************"

# http probes
for period in ${probe_periods}; do
  probes="--startup-probe http,0,${period},1,12 --liveness-probe http,0,${period},1,3 --readiness-probe http,0,${period},1,3,1"
  probe_title="probes (${period}s period)s"
  echo "$(date -u +%Y%m%d-%H%M%S) - Probes: ${probes}"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, 1 deploy, ${total_pods} pods, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-1d-${total_pods}p-1c-gohttp-${period}-http" -n 1 -d 1 -p ${total_pods} -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, ${total_pods} deploys, 1 pod, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-${total_pods}d-1p-1c-gohttp-${period}-http" -n 1 -d ${total_pods} -p 1 -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-gohttp-${period}-http" -n ${total_pods} -d 1 -p 1 -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

# tcp probes
for period in ${probe_periods}; do
  probes="--startup-probe tcp,0,${period},1,12 --liveness-probe tcp,0,${period},1,3 --readiness-probe tcp,0,${period},1,3,1"
  probe_title="tcp probes (${period}s period)s"
  echo "$(date -u +%Y%m%d-%H%M%S) - Probes: ${probes}"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, 1 deploy, ${total_pods} pods, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-1d-${total_pods}p-1c-gohttp-${period}-tcp" -n 1 -d 1 -p ${total_pods} -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, ${total_pods} deploys, 1 pod, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-${total_pods}d-1p-1c-gohttp-${period}-tcp" -n 1 -d ${total_pods} -p 1 -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-gohttp-${period}-tcp" -n ${total_pods} -d 1 -p 1 -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

# exec probes
for period in ${probe_periods}; do
  probes="--startup-probe exec,0,${period},1,12 --liveness-probe exec,0,${period},1,3 --readiness-probe exec,0,${period},1,3,1"
  probe_title="tcp probes (${period}s period)s"
  echo "$(date -u +%Y%m%d-%H%M%S) - Probes: ${probes}"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, 1 deploy, ${total_pods} pods, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-1d-${total_pods}p-1c-gohttp-${period}-exec" -n 1 -d 1 -p ${total_pods} -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - 1 namespace, ${total_pods} deploys, 1 pod, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "1n-${total_pods}d-1p-1c-gohttp-${period}-exec" -n 1 -d ${total_pods} -p 1 -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"

  test_index=$((${test_index} + 1))
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} - ${total_pods} namespaces, 1 deploy, 1 pod, 1 container (gohttp), 1 service, ${probe_title}, 0 configmaps, 0 secrets"
  logfile="../logs/$(date -u +%Y%m%d-%H%M%S)-nodedensity-5.${test_index}.log"
  ../../boatload/boatload.py ${dryrun} ${csvfile} --csv-title "${total_pods}n-1d-1p-1c-gohttp-${period}-exec" -n ${total_pods} -d 1 -p 1 -c 1 -l -m 0 --secrets 0 ${probes} ${gohttp_env_vars} ${measurement} ${INDEX_ARGS} &> ${logfile}
  echo "$(date -u +%Y%m%d-%H%M%S) - node density 5.${test_index} complete, sleeping ${sleep_period}"
  sleep ${sleep_period}
  echo "****************************************************************************************************************************************"
done

echo "$(date -u +%Y%m%d-%H%M%S) - Test Case 5 Complete"
