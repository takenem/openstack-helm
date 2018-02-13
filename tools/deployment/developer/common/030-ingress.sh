#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Pull images and lint chart
make pull-images ingress

#NOTE: Deploy command
: ${EXTRA_CONFIG:=""}
tee /tmp/ingress-kube-system.yaml << EOF
deployment:
  mode: cluster
  type: DaemonSet
network:
  host_namespace: true
EOF
helm upgrade --install ingress-kube-system ./ingress \
  --namespace=kube-system \
  --values=/tmp/ingress-kube-system.yaml \
  ${EXTRA_CONFIG}

#NOTE: Deploy namespace ingress
helm upgrade --install ingress-openstack ./ingress \
  --namespace=openstack

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Display info
helm status ingress-kube-system
helm status ingress-openstack
