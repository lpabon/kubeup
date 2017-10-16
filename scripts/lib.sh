
# Util functions

fail() {
    echo "==> ERROR: $@"
    exit 1
}

println() {
    echo "--> $1"
}

_sudo() {
    if [ ${UID} = 0 ] ; then
        ${@}
    else
        sudo -E ${@}
    fi
}

# Kubernetes functions

# $1 namespace
# $2 name
get_node_port_from_service() {
    kubectl -n "$1" get svc "$2" -o json | jq '.spec.ports[0].nodePort'
}

# $1 namespace
# $2 name
# $3 number of expected running pods
wait_for_pod_ready() {
    # Wait until all pods are in Running state
    n=0
    until [ `kubectl -n "$1" get pods 2>/dev/null | grep "$2" | grep Running | grep "1/1" | wc -l` -eq $3 ] ; do
        n=$[$n+1]
        if [ $n -gt 1200 ] ; then
            fail "Timed out waiting for $2 to start"
        fi
        sleep 1
    done
}

# $1 namespace
# $2 name
wait_for_pods_deleted() {
    # Wait until all pods are removed
    n=0
    while kubectl -n "$1" get pods 2>/dev/null | grep "$2" > /dev/null 2>&1 ; do
        n=$[$n+1]
        if [ $n -gt 600 ] ; then
            fail "Timed out waiting for $2 to be deleted"
        fi
        sleep 1
    done
}

# $1 namespace
# $2 name
wait_for_pvc_bound() {
	n=0
    until `kubectl -n "$1" get pvc 2>/dev/null | grep "$2" | grep Bound > /dev/null 2>&1` ; do
        n=$[$n+1]
        if [ $n -gt 600 ] ; then
            fail "Timed out waiting for pvc to be deleted"
        fi
        sleep 1
    done
}

# $1 namespace
# $2 name
wait_for_pvc_deleted() {
	n=0
    while `kubectl -n "$1" get pvc 2>/dev/null | grep "$2" > /dev/null 2>&1` ; do
        n=$[$n+1]
        if [ $n -gt 600 ] ; then
            fail "Timed out waiting for pvc to be deleted"
        fi
        sleep 1
    done
    sleep 10
}