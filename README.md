# boatload

Workloads for OpenShift/Kubernetes clusters.

- [boatload](#boatload)
  - [Overview](#overview)
  - [Labels for boatload workload](#labels-for-boatload-workload)
  - [Running boatload workload](#running-boatload-workload)
  - [boatload workload object hierarchy](#boatload-workload-object-hierarchy)
  - [boatload image preloading](#boatload-image-preloading)
  - [boatload workload container resource configuration](#boatload-workload-container-resource-configuration)
  - [boatload workload container image configuration](#boatload-workload-container-image-configuration)
  - [boatload workload container probe configuration](#boatload-workload-container-probe-configuration)
  - [boatload workload container environment configuration](#boatload-workload-container-environment-configuration)
  - [boatload workload pod annotations configuration](#boatload-workload-pod-annotations-configuration)
  - [boatload workload cleanup](#boatload-workload-cleanup)

## Overview

The boatload workload is designed to stress test node density and remote worker node clusters.

1. Clone the repo to a bastion machine
2. Ensure [kube-burner](https://github.com/cloud-bulldozer/kube-burner) is installed (Version `v0.14.3`)
3. Install python requirements - `pip3 install -r requirements.txt`
4. (Optional) Label nodes with `labeler.py` (Generally for remote worker node workloads)
5. (Optional) [Preload images](#boatload-image-preloading) onto nodes
6. Run `boatload.py`

```console
$ virtualenv .venv
$ source .venv/bin/activate
$ pip3 install -r requirements.txt
$ ./boatload/boatload.py -h
```

## Labels for boatload workload

Prior to running boatload workloads with selectors, you must create a number of labels beforehand.

Create 100 shared labels across the remote worker nodes:

```console
$ ./boatload/labeler.py -c 100 -s
```

Create 100 unique labels per node per boatload workload pod:

```console
$ ./boatload/labeler.py -c 100 -u
```

Clear all 100 shared and unique labels off the remote worker nodes:

```console
$ ./boatload/labeler.py -c 100 -su --clear
```

## Running boatload workload

Pre-reqs:

* Authenticated to cluster under test

Additional Pre-req for Remote Worker Node Test Environments:

* Run on Bastion machine to apply network impairments

The boatload workload runs in several distinct phases:

1. Workload - Load cluster with Namespaces, Deployments, Pods, Services, Routes, ConfigMaps, and Secrets
2. Measurement - Period of time to allow for measurements/metrics while cluster is loaded, and optional network impairments for a duration
3. Cleanup - Cleanup workload off cluster
4. Metrics - Metrics are collected from prometheus by kube-burner and can be indexed

Each phase can be disabled if intended during testing via arguments. The impairments that can be used are network bandwidth limits, latency, packet loss and link flapping. Bandwidth, latency, and packet loss can only be combined with link flapping if the firewall option is set. Review the arguments to see all the options for each phase.

boatload workload arguments:

```console
$ ./boatload/boatload.py -h
usage: boatload.py [-h] [--no-workload-phase] [--no-measurement-phase] [--no-cleanup-phase] [--no-metrics-phase] [-n NAMESPACES] [-d DEPLOYMENTS] [-l] [-r] [-p PODS] [-c CONTAINERS]
                   [--enable-pod-annotations] [-a [POD_ANNOTATIONS ...]] [-i CONTAINER_IMAGE] [--container-port CONTAINER_PORT] [-e [CONTAINER_ENV ...]] [-m CONFIGMAPS] [--secrets SECRETS]
                   [--cpu-requests CPU_REQUESTS] [--memory-requests MEMORY_REQUESTS] [--cpu-limits CPU_LIMITS] [--memory-limits MEMORY_LIMITS] [--startup-probe STARTUP_PROBE]
                   [--liveness-probe LIVENESS_PROBE] [--readiness-probe READINESS_PROBE] [--startup-probe-endpoint STARTUP_PROBE_ENDPOINT] [--liveness-probe-endpoint LIVENESS_PROBE_ENDPOINT]
                   [--readiness-probe-endpoint READINESS_PROBE_ENDPOINT] [--startup-probe-exec-command STARTUP_PROBE_EXEC_COMMAND] [--liveness-probe-exec-command LIVENESS_PROBE_EXEC_COMMAND]
                   [--readiness-probe-exec-command READINESS_PROBE_EXEC_COMMAND] [--no-probes] [--default-selector DEFAULT_SELECTOR] [-s SHARED_SELECTORS] [-u UNIQUE_SELECTORS] [-o OFFSET] [--tolerations]
                   [-q KB_QPS] [-b KB_BURST] [-D DURATION] [-I INTERFACE] [-S START_VLAN] [-E END_VLAN] [-L LATENCY] [-P PACKET_LOSS] [-B BANDWIDTH_LIMIT] [-F LINK_FLAP_DOWN] [-U LINK_FLAP_UP] [-T]
                   [-N LINK_FLAP_NETWORK] [--metrics-profile METRICS_PROFILE] [--prometheus-url PROMETHEUS_URL] [--prometheus-token PROMETHEUS_TOKEN] [--metrics [METRICS ...]]
                   [--index-server INDEX_SERVER] [--default-index DEFAULT_INDEX] [--measurements-index MEASUREMENTS_INDEX] [--csv-results-file CSV_RESULTS_FILE] [--csv-metrics-file CSV_METRICS_FILE]
                   [--csv-title CSV_TITLE] [--cleanup] [--debug] [--dry-run] [--reset]

Run boatload

optional arguments:
  -h, --help            show this help message and exit
  --no-workload-phase   Disables workload phase (default: False)
  --no-measurement-phase
                        Disables measurement phase (default: False)
  --no-cleanup-phase    Disables cleanup phase (default: False)
  --no-metrics-phase    Disables metrics phase (default: False)
  -n NAMESPACES, --namespaces NAMESPACES
                        Number of namespaces to create (default: 1)
  -d DEPLOYMENTS, --deployments DEPLOYMENTS
                        Number of deployments per namespace to create (default: 1)
  -l, --service         Include service per deployment (default: False)
  -r, --route           Include route per deployment (default: False)
  -p PODS, --pods PODS  Number of pod replicas per deployment to create (default: 1)
  -c CONTAINERS, --containers CONTAINERS
                        Number of containers per pod replica to create (default: 1)
  --enable-pod-annotations
                        Enable pod annotations (default: False)
  -a [POD_ANNOTATIONS ...], --pod-annotations [POD_ANNOTATIONS ...]
                        The pod annotations (default: ['k8s.v1.cni.cncf.io/networks=\'[{"name": "net1", "namespace": "default"}]\''])
  -i CONTAINER_IMAGE, --container-image CONTAINER_IMAGE
                        The container image to use (default: quay.io/redhat-performance/test-gohttp-probe:v0.0.2)
  --container-port CONTAINER_PORT
                        The starting container port to expose (PORT Env Var) (default: 8000)
  -e [CONTAINER_ENV ...], --container-env [CONTAINER_ENV ...]
                        The container environment variables (default: ['LISTEN_DELAY_SECONDS=20', 'LIVENESS_DELAY_SECONDS=10', 'READINESS_DELAY_SECONDS=30', 'RESPONSE_DELAY_MILLISECONDS=50',
                        'LIVENESS_SUCCESS_MAX=60', 'READINESS_SUCCESS_MAX=30'])
  -m CONFIGMAPS, --configmaps CONFIGMAPS
                        Number of configmaps per container (default: 0)
  --secrets SECRETS     Number of secrets per container (default: 0)
  --cpu-requests CPU_REQUESTS
                        CPU requests per container (millicores) (default: 0)
  --memory-requests MEMORY_REQUESTS
                        Memory requests per container (MiB) (default: 0)
  --cpu-limits CPU_LIMITS
                        CPU limits per container (millicores) (default: 0)
  --memory-limits MEMORY_LIMITS
                        Memory limits per container (MiB) (default: 0)
  --startup-probe STARTUP_PROBE
                        Container startupProbe configuration (default: http,0,10,1,12)
  --liveness-probe LIVENESS_PROBE
                        Container livenessProbe configuration (default: http,0,10,1,3)
  --readiness-probe READINESS_PROBE
                        Container readinessProbe configuration (default: http,0,10,1,3,1)
  --startup-probe-endpoint STARTUP_PROBE_ENDPOINT
                        startupProbe endpoint (default: /livez)
  --liveness-probe-endpoint LIVENESS_PROBE_ENDPOINT
                        livenessProbe endpoint (default: /livez)
  --readiness-probe-endpoint READINESS_PROBE_ENDPOINT
                        readinessProbe endpoint (default: /readyz)
  --startup-probe-exec-command STARTUP_PROBE_EXEC_COMMAND
                        startupProbe exec command (default: test -f /tmp/startup)
  --liveness-probe-exec-command LIVENESS_PROBE_EXEC_COMMAND
                        livenessProbe exec command (default: test -f /tmp/liveness)
  --readiness-probe-exec-command READINESS_PROBE_EXEC_COMMAND
                        readinessProbe exec command (default: test -f /tmp/readiness)
  --no-probes           Disable all probes (default: False)
  --default-selector DEFAULT_SELECTOR
                        Default node-selector (default: jetlag: 'true')
  -s SHARED_SELECTORS, --shared-selectors SHARED_SELECTORS
                        How many shared node-selectors to use (default: 0)
  -u UNIQUE_SELECTORS, --unique-selectors UNIQUE_SELECTORS
                        How many unique node-selectors to use (default: 0)
  -o OFFSET, --offset OFFSET
                        Offset for iterated unique node-selectors (default: 0)
  --tolerations         Include RWN tolerations on pod spec (default: False)
  -q KB_QPS, --kb-qps KB_QPS
                        kube-burner qps setting (default: 20)
  -b KB_BURST, --kb-burst KB_BURST
                        kube-burner burst setting (default: 40)
  -D DURATION, --duration DURATION
                        Duration of measurement/impairment phase (Seconds) (default: 30)
  -I INTERFACE, --interface INTERFACE
                        Interface of vlans to impair (default: ens1f1)
  -S START_VLAN, --start-vlan START_VLAN
                        Starting VLAN off interface (default: 100)
  -E END_VLAN, --end-vlan END_VLAN
                        Ending VLAN off interface (default: 105)
  -L LATENCY, --latency LATENCY
                        Amount of latency to add to all VLANed interfaces (milliseconds) (default: 0)
  -P PACKET_LOSS, --packet-loss PACKET_LOSS
                        Percentage of packet loss to add to all VLANed interfaces (default: 0)
  -B BANDWIDTH_LIMIT, --bandwidth-limit BANDWIDTH_LIMIT
                        Bandwidth limit to apply to all VLANed interfaces (kilobits). 0 for no limit. (default: 0)
  -F LINK_FLAP_DOWN, --link-flap-down LINK_FLAP_DOWN
                        Time period to flap link down (Seconds) (default: 0)
  -U LINK_FLAP_UP, --link-flap-up LINK_FLAP_UP
                        Time period to flap link up (Seconds) (default: 0)
  -T, --link-flap-firewall
                        Flaps links via iptables instead of ip link set (default: False)
  -N LINK_FLAP_NETWORK, --link-flap-network LINK_FLAP_NETWORK
                        Network to block for iptables link flapping (default: 198.18.10.0/24)
  --metrics-profile METRICS_PROFILE
                        Metrics profile for kube-burner (default: metrics.yaml)
  --prometheus-url PROMETHEUS_URL
                        Cluster prometheus URL (default: )
  --prometheus-token PROMETHEUS_TOKEN
                        Token to access prometheus (default: )
  --metrics [METRICS ...]
                        List of metrics to collect into metrics.csv (default: ['nodeReadyStatus', 'nodeCoresUsed', 'nodeMemoryConsumed', 'kubeletCoresUsed', 'kubeletMemory', 'crioCoresUsed',
                        'crioMemory'])
  --index-server INDEX_SERVER
                        ElasticSearch server (Ex https://user:password@example.org:9200) (default: )
  --default-index DEFAULT_INDEX
                        Default index (default: boatload-default)
  --measurements-index MEASUREMENTS_INDEX
                        Measurements index (default: boatload-default)
  --csv-results-file CSV_RESULTS_FILE
                        Determines results csv to append to (default: results.csv)
  --csv-metrics-file CSV_METRICS_FILE
                        Determines metrics csv to append to (default: metrics.csv)
  --csv-title CSV_TITLE
                        Determines title of row of data (default: untitled)
  --cleanup             Shortcut to only run cleanup phase (default: False)
  --debug               Set log level debug (default: False)
  --dry-run             Echos commands instead of executing them (default: False)
  --reset               Attempts to undo all network impairments (default: False)
```

## boatload workload object hierarchy

The boatload workload creates objects in a hierarchy:

* Namespaces
  * Deployments per namespace
    * 1 Service per deployment (if enabled)
    * 1 Route per deployment (if enabled)
    * Pods per deployment
      * Containers per pod

Thus if you want to create 100 pods you can do so in more than one hierarchy:

```console
$ ./boatload.py -n 1 -d 50 -p 2
```

The above command creates 1 namespace with 50 deployments, each with 2 pod replicas resulting in 100 pods.

As another example:

```console
$ ./boatload.py -n 10 -d 10 -p 1
```

The above command creates 10 namespaces with 10 deployments, each with 1 pod replica resulting in 100 pods.

To create a service per deployment which will expose and load balance traffic to pod replicas, use the `-l` argument. This is used when you have a readiness probe so that kubernetes must handle endpoints if readiness flaps or fails.

## boatload image preloading

A manifest is included in the boatload repo to facilitate preloading container images to all nodes in a cluster. Prior to running any benchmarks it is best to apply the preload manifest such that the container images are pulled into each node. Subsequently you can delete the preload manifest to remove the extra namespace and daemonset it creates after the pods are running.

```console
$ oc apply -f manifests/
namespace/boatload-preload created
daemonset.apps/boatload-preload created
$ oc get po -n boatload-preload
NAME                     READY   STATUS    RESTARTS   AGE
boatload-preload-7vw9j   3/3     Running   0          23s
boatload-preload-9p2fq   3/3     Running   0          23s
boatload-preload-cz7bd   3/3     Running   0          23s
$ oc delete -f manifests/
namespace "boatload-preload" deleted
daemonset.apps "boatload-preload" deleted
```

## boatload workload container resource configuration

The boatload workload allows you to set cpu and memory requests/limits at the container level. The following arguments set the cpu and memory resources:

* `--cpu-requests CPU_REQUESTS`
* `--memory-requests MEMORY_REQUESTS`
* `--cpu-limits CPU_LIMITS`
* `--memory-limits MEMORY_LIMITS`

CPU requests and limits is in millicores, thus `1000` equals 1 cpu core. Memory requests and limits is in MiB, thus `1024` equals 1 GiB. Keep in mind total cluster capacity when setting requests and limits and whether the expected workload will be able to be scheduled into the cluster under test. Depending upon the argument values here you will affect whether or not the pods QoS is either Best-Effort, Burstable, or Guaranteed.

## boatload workload container image configuration

The boatload workload allows setting a custom image with the containers it deploys. Use the `-i` option to change the container image. The default container image is `quay.io/redhat-performance/test-gohttp-probe:v0.0.2`. The `test-gohttp-probe` container image exposes a `livez` and `readyz` endpoint so you can easily test probe configuration in conjunction with various object hierarchies.

An example of a container image that works with all probes disabled is the pause image.

```console
$ ./boatload.py -i 'gcr.io/google_containers/pause-amd64:3.0' --no-probes
```

## boatload workload container probe configuration

If you use the default container image `quay.io/redhat-performance/test-gohttp-probe:v0.0.2`, you can use startup, liveness, and readiness probes. The defaults work but you might want to configure the various probe options or a different image might use different endpoints. The probe configuration arguments are:

* `--startup-probe STARTUP_PROBE`
* `--liveness-probe LIVENESS_PROBE`
* `--readiness-probe READINESS_PROBE`
* `--startup-probe-endpoint STARTUP_PROBE_ENDPOINT`
* `--liveness-probe-endpoint LIVENESS_PROBE_ENDPOINT`
* `--readiness-probe-endpoint READINESS_PROBE_ENDPOINT`
* `--startup-probe-exec-command STARTUP_PROBE_EXEC_COMMAND`
* `--liveness-probe-exec-command LIVENESS_PROBE_EXEC_COMMAND`
* `--readiness-probe-exec-command READINESS_PROBE_EXEC_COMMAND`
* `--no-probes`

Each probe (startup/liveness/readiness) takes a comma separated string for configuration that consists of the probe type followed by 4 or 5 integer values. The endpoint arguments simply take a string of what endpoint is expected for which probe for the specific application when using http probes. The exec command arguments are only for adjusting what command to run with an exec probe.

```console
$ ./boatload.py --startup-probe http,0,10,1,12 --liveness-probe http,0,10,1,3 --readiness-probe http,0,10,1,3,1
```

The first option in the comma separated string can be either `http`, `tcp`, `exec`, or `off`. The remaining options are all integers and configure these probe options in the order shown:

```yaml
initialDelaySeconds: 0
periodSeconds: 10
timeoutSeconds: 1
failureThreshold: 12
successThreshold: 1
```

See this [kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes) that describes each configuration item. Note that startup and liveness probes must configure `successThreshold` to value `1`. Since it is the last argument, it can be left off so the default is consumed for both those probes.

Configuring an exec probe command looks like this:

```console
$ ./boatload.py --startup-probe exec,0,10,1,12 --startup-probe-exec-command "test\n-f\n/tmp/startup"
```

## boatload workload container environment configuration

The boatload workload can configure custom environmental variables with passed in arguments. The `-e` argument is used to define the custom environment variables.

```console
./boatload.py -e LISTEN_DELAY_SECONDS=20 LIVENESS_DELAY_SECONDS=10 READINESS_DELAY_SECONDS=30 RESPONSE_DELAY_MILLISECONDS=50 LIVENESS_SUCCESS_MAX=60 READINESS_SUCCESS_MAX=30
```

This results in the following environment variable configuration for each container boatload workload creates:

```yaml
env:
- name: PORT
  value: "8001"
- name: LISTEN_DELAY_SECONDS
  value: "60"
- name: LIVENESS_DELAY_SECONDS
  value: "10"
- name: READINESS_DELAY_SECONDS
  value: "30"
- name: RESPONSE_DELAY_MILLISECONDS
  value: "50"
- name: LIVENESS_SUCCESS_MAX
  value: "60"
- name: READINESS_SUCCESS_MAX
  value: "30"
```

The `PORT` environment variable is provided automatically and incremented based on the number of containers specified (`-c` argument). Combined with container image `quay.io/redhat-performance/test-gohttp-probe`, these environment vars configure the behavior of the app to the kubernetes probes. The example provided is actually the default.

## boatload workload pod annotations configuration

Custom pod annotations can be added to each deployment pod template spec. This allows applying configurations such as a second network for the workload pod. This example cli passes in an annotation that adds a second network interface to the workload pod from network-attachment-definition `net1` in namespace `default`.

```console
$ ./boatload/boatload.py --enable-pod-annotations --pod-annotations k8s.v1.cni.cncf.io/networks=\''[{"name": "net1", "namespace": "default"}]'\'
```

Example of passing multiple pod annotations via cli in Bash shell.

```console
$ ./boatload/boatload.py --enable-pod-annotations -a k8s.v1.cni.cncf.io/networks=\''[{"name": "net1", "namespace": "default"}]'\' test=\''true'\'
```

## boatload workload cleanup

The `--cleanup` flag allows you to quickly run only the cleanup phase of the boatload workload in the event testing has caused a large enough failure that removal of the workload is necessary.

```console
$ ./boatload/boatload.py --cleanup
```
