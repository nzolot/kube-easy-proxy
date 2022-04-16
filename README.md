# Description

This is simple nginx proxy that allow to forward traffic to endpoints inside or outsite the kubernetes cluster.

The main use case for creating this mini-project is to forward traffic to external host based on DNS instead on IP address



# Build
docker build . -t nzolot/kube-easy-proxy:1.0.x

docker push nzolot/kube-easy-proxy:1.0.x
