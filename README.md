# k8s-gke-playground
Helper scripts for my personal K8s playground setup with GKE

## Prerequisites

    brew install cfssl google-cloud-sdk

## Pricing

Get an overview of default (predefined) machine types for GKE clusters [here][predefined-instanc-pricing].

The cluster setup script is using the predefined machine type of **```n1-standard-2```** in **```us-east-1```** with the **```preemtible```** option set. Preemptible means, that the running instances can be shut down at any time without further notice. GKE should be able to handle the loss of node(s) and start new instances automatically. Your software running on K8s should be able to recover from a node loss as well. All changes done on the K8s worker nodes will be lost (use DaemonSets to make changes on the host machines).

You can get a list of the predefined machine types by running:

    gcloud compute machine-types list

### Price calculations (preemtible machines)

#### [n1-standard-1 instances][compute-machine-types]
|      price  |   unit   | multiplier  |           total |
|------------:|:--------:|-------------|----------------:|
|       $0.01 |   hour   | 3 instances |       $0.03 / h |
|       $0.03 |   hour   | 24 hours    |       $0.72 / d |
|   **$0.72** | **day**  | **31** days |  **$22.32 / m** |

#### [n1-standard-2 instances (currently set)][compute-machine-types]
| price       |   unit   | multiplier  |           total |
|------------:|:--------:|-------------|----------------:|
|       $0.02 |   hour   | 3 instances |       $0.06 / h |
|       $0.06 |   hour   | 24 hours    |       $1.44 / d |
|   **$1.44** | **day**  | **31** days |  **$44.64 / m** |

#### [n1-standard-4 instances][compute-machine-types]
| price       |   unit   | multiplier  |           total |
|------------:|:--------:|-------------|----------------:|
|       $0.04 |   hour   | 3 instances |       $0.12 / h |
|       $0.12 |   hour   | 24 hours    |       $2.88 / d |
|   **$2,88** | **day**  | **31** days |  **$89.28 / m** |

#### [n1-standard-8 instances][compute-machine-types]
| price       |   unit   | multiplier  |           total |
|------------:|:--------:|-------------|----------------:|
|       $0.08 |   hour   | 3 instances |       $0.24 / h |
|       $0.24 |   hour   | 24 hours    |       $5.76 / d |
|   **$5.76** | **day**  | **31** days | **$178.56 / m** |

#### [n1-standard-16 instances][compute-machine-types]
| price       |   unit   | multiplier  |           total |
|------------:|:--------:|-------------|----------------:|
|       $0.16 |   hour   | 3 instances |       $0.48 / h |
|       $0.48 |   hour   | 24 hours    |      $11.52 / d |
|  **$11.52** | **day**  | **31** days | **$357.12 / m** |



## Google Cloud compute resources

Regions and zones can be found in the official [documentation][available-regions-zones] or by running:

    gcloud compute zones list



## Google Cloud Container resources

To get valid container image types, run:

    gcloud container get-server-config \
      --format json | jq '.validImageTypes'

Versions for Kubernetes master and worker nodes. Worker node version cannot be higher then the master node version. To get valid versions, run:

    gcloud container get-server-config \
      --format json | jq '.validMasterVersions'
    
    gcloud container get-server-config \
      --format json | jq '.validNodeVersions'



## Cluster upgrades

The automatic node upgrade functionality is enabled in the scripts and might happen at any given time. To read more about the topic and how GKE is handling that task, refer to [the guides for automatic cluster node upgrades][node-auto-upgrades].



## Cluster hardening

Most of the best practices described in the [documentation][hardening-the-cluster] are already included in the [cluster-create script][cluster-create-script].

> It is worth to mention that it is not recommended to deploy the Kubernetes Dashboard Addon on GKE, as it is running with high priviledges and most of the functionality is already present in the GKE dashboards. If it is needed for any reason, just run the script [04-addon-k8s-dashboard.sh][addon-k8s-dashboard-script].





[predefined-instanc-pricing]: https://cloud.google.com/compute/pricing#predefined
[compute-machine-types]: https://cloud.google.com/compute/docs/machine-types#standard_machine_types
[available-regions-zones]: https://cloud.google.com/compute/docs/regions-zones/#available
[hardening-the-cluster]: https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster
[cluster-create-script]: http://01-cluster-create.sh
[node-auto-upgrades]: https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-upgrades
[addon-k8s-dashboard-script]: file://04-cluster-resize.sh