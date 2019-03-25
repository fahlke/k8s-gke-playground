#!/bin/bash

# remove coredns ServiceMonitor (currently not used in the cluster)
kubectl -n monitoring delete ServiceMonitor prometheus-prometheus-oper-coredns