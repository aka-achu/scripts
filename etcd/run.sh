# cleaning up existing containers if any
ids=$(docker ps --filter name=etcd-node* -aq)
if [ ${#ids} != 0 ]
then
    docker ps --filter name=etcd-node* -aq | xargs docker stop | xargs docker rm
fi

# cleaning up existing data volumes if any
volumes=$(docker volume ls --filter name=etcd-node* -q)
if [ ${#ids} != 0 ]
then
    docker volume ls --filter name=etcd-node* -q | xargs docker volume rm
fi

# docker image registry for etcd
REGISTRY=quay.io/coreos/etcd
# version of etcd to pull from the docker image registry
ETCD_VERSION=v3.4.15

# pre-shared cluster token
TOKEN=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)

CLUSTER_STATE=new
PORT_MULTIPLIER=10000

# command line flags
#   n -> number of nodes in the cluster
#   h -> ip address of the hostl 

while getopts n:h: flag
do
    case "${flag}" in
        n) NODES=${OPTARG};;
        h) HOST=${OPTARG};;
    esac
done

# genrating CA and server certificates
mkdir -p certs
mkdir -p certs/ca
cfssl gencert --initca ./config/ca-csr.json | cfssljson -bare ./certs/ca/ca

index=0  
while [ $index -lt $NODES ]; do  

    NAME=etcd-node-${index}
    ADDRESS=127.0.0.1,$HOST,$NAME,172.17.0.1
    mkdir -p certs/"node-$index"

    echo '{"CN":"'$NAME'","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert \
                                                                                -config=./config/ca-config.json \
                                                                                -ca=./certs/ca/ca.pem \
                                                                                -ca-key=./certs/ca/ca-key.pem \
                                                                                -hostname="$ADDRESS" - | cfssljson -bare ./certs/"node-$index"/server

    index=$((index+1));
done

# forming the initial-cluster details
CLUSTER=""
index=0  
while [ $index -lt $NODES ]; do  
    eval CLUSTER+=etcd-node-${index}=https://$HOST:$((2380+$index*$PORT_MULTIPLIER)),
    index=$((index+1));
done

# forming the etcd cluster
index=0
while [ $index -lt $NODES ]; do  
    docker volume create etcd-node-${index}-data
    echo $(pwd)"/certs/"etcd-node-${index}
    docker run \
        -d \
        -p $((2379+$index*$PORT_MULTIPLIER)):$((2379+$index*$PORT_MULTIPLIER)) \
        -p $((2380+$index*$PORT_MULTIPLIER)):$((2380+$index*$PORT_MULTIPLIER)) \
        --volume=etcd-node-${index}-data:/etcd-data \
        --volume="$(pwd)"/certs/ca:/etc/etcd/certs/ca \
        --volume="$(pwd)"/certs/"node-$index":/etc/etcd/certs/tls \
        --name etcd-node-${index} ${REGISTRY}:${ETCD_VERSION} \
        /usr/local/bin/etcd \
        --data-dir=/etcd-data \
        --name etcd-node-${index} \
        --initial-advertise-peer-urls https://${HOST}:$((2380+$index*$PORT_MULTIPLIER)) \
        --listen-peer-urls https://0.0.0.0:$((2380+$index*$PORT_MULTIPLIER)) \
        --advertise-client-urls https://${HOST}:$((2379+$index*$PORT_MULTIPLIER)) \
        --listen-client-urls https://0.0.0.0:$((2379+$index*$PORT_MULTIPLIER)) \
        --initial-cluster ${CLUSTER::-1} \
        --initial-cluster-state ${CLUSTER_STATE} \
        --initial-cluster-token ${TOKEN} \
        --client-cert-auth \
        --trusted-ca-file=/etc/etcd/certs/ca/ca.pem \
        --cert-file=/etc/etcd/certs/tls/server.pem \
        --key-file=/etc/etcd/certs/tls/server-key.pem \
        --peer-client-cert-auth \
        --peer-trusted-ca-file=/etc/etcd/certs/ca/ca.pem \
        --peer-cert-file=/etc/etcd/certs/tls/server.pem \
        --peer-key-file=/etc/etcd/certs/tls/server-key.pem

    index=$((index+1));
done

# generating client certificates
echo '{"CN":"client","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert \
                                                                                -config=./config/ca-config.json \
                                                                                -ca=./certs/ca/ca.pem \
                                                                                -ca-key=./certs/ca/ca-key.pem - | cfssljson -bare ./certs/client