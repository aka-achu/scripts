
# docker image registry for etcd
REGISTRY=gcr.io/etcd-development/etcd
# version of etcd to pull from the docker image registry
ETCD_VERSION=latest

# pre-shared cluster token
TOKEN=GUQujf9NdVzAMgaR2Dpfy6LPnksp46hn

CLUSTER_STATE=new

# names for etcd cluster nodes
NAME_1=etcd-node-0
NAME_2=etcd-node-1
NAME_3=etcd-node-2

# hosts of cluster nodes
HOST_1=159.65.149.70
HOST_2=159.65.149.70
HOST_3=159.65.149.70

# advertise and peer ports of cluster nodes
HOST_1_CLIENT_PORT=1379
HOST_1_PEER_PORT=1380
HOST_2_CLIENT_PORT=2379
HOST_2_PEER_PORT=2380
HOST_3_CLIENT_PORT=3379
HOST_3_PEER_PORT=3380


CLUSTER=${NAME_1}=http://${HOST_1}:${HOST_1_PEER_PORT},${NAME_2}=http://${HOST_2}:${HOST_2_PEER_PORT},${NAME_3}=http://${HOST_3}:${HOST_3_PEER_PORT}

# creating docker volumes to etcd dat persistence
docker volume create etcd_data_1
docker volume create etcd_data_2
docker volume create etcd_data_3


# creating node 1
docker run \
  -d \
  -p ${HOST_1_CLIENT_PORT}:${HOST_1_CLIENT_PORT} \
  -p ${HOST_1_PEER_PORT}:${HOST_1_PEER_PORT} \
  --volume=etcd_data_1:/etcd-data \
  --name ${NAME_1} ${REGISTRY}:${ETCD_VERSION} \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data \
  --name ${NAME_1} \
  --initial-advertise-peer-urls http://${HOST_1}:${HOST_1_PEER_PORT} \
  --listen-peer-urls http://0.0.0.0:${HOST_1_PEER_PORT} \
  --advertise-client-urls http://${HOST_1}:${HOST_1_CLIENT_PORT} \
  --listen-client-urls http://0.0.0.0:${HOST_1_CLIENT_PORT} \
  --initial-cluster ${CLUSTER} \
  --initial-cluster-state ${CLUSTER_STATE} \
  --initial-cluster-token ${TOKEN}


# creating node 2
docker run \
  -d \
  -p ${HOST_2_CLIENT_PORT}:${HOST_2_CLIENT_PORT} \
  -p ${HOST_2_PEER_PORT}:${HOST_2_PEER_PORT} \
  --volume=etcd_data_2:/etcd-data \
  --name ${NAME_2} ${REGISTRY}:${ETCD_VERSION} \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data \
  --name ${NAME_2} \
  --initial-advertise-peer-urls http://${HOST_2}:${HOST_2_PEER_PORT} \
  --listen-peer-urls http://0.0.0.0:${HOST_2_PEER_PORT} \
  --advertise-client-urls http://${HOST_2}:${HOST_2_CLIENT_PORT} \
  --listen-client-urls http://0.0.0.0:${HOST_2_CLIENT_PORT} \
  --initial-cluster ${CLUSTER} \
  --initial-cluster-state ${CLUSTER_STATE} \
  --initial-cluster-token ${TOKEN}
  
  # creating node 3
docker run \
  -d \
  -p ${HOST_3_CLIENT_PORT}:${HOST_3_CLIENT_PORT} \
  -p ${HOST_3_PEER_PORT}:${HOST_3_PEER_PORT} \
  --volume=etcd_data_3:/etcd-data \
  --name ${NAME_3} ${REGISTRY}:${ETCD_VERSION} \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data \
  --name ${NAME_3} \
  --initial-advertise-peer-urls http://${HOST_3}:${HOST_3_PEER_PORT} \
  --listen-peer-urls http://0.0.0.0:${HOST_3_PEER_PORT} \
  --advertise-client-urls http://${HOST_3}:${HOST_3_CLIENT_PORT} \
  --listen-client-urls http://0.0.0.0:${HOST_3_CLIENT_PORT} \
  --initial-cluster ${CLUSTER} \
  --initial-cluster-state ${CLUSTER_STATE} \
  --initial-cluster-token ${TOKEN}
