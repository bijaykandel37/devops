helm repo add portainer https://portainer.github.io/k8s/
helm repo update
helm install portainer portainer/portainer   --namespace namespacename   --set persistence.enabled=false   --set service.type=LoadBalancer

helm uninstall portainer -n namespacename


echo 'apiVersion: v1
kind: PersistentVolume
metadata:
  name: portainer-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: gp3  # Change based on your StorageClass
  hostPath:
    path: "/data/portainer"
' > portainer-pv.yml

kubectl apply -f portainer-pv.yml -n namespacename
