# Jellyfin



## Copy files to pvc via pod
```sh
# create dir
kubectl exec -it jellyfin-pod -n jellyfin -- /bin/bash
# copy the dir mydir into /media/TV -> /media/TV/mydir
kubectl cp mydir/ jellyfin-pod:/media/TV -n jellyfin
# copy contents of mydir into /media/TV -> media/TV
kubectl cp mydir/ jellyfin-pod:/media/TV/ -n jellyfin
```
