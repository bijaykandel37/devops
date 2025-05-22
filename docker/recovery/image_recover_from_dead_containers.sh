##To export 
docker export -o output.tar container_name

##To Import
docker import output.tar new_image_name:tag


##OR use docker load and save for multiple files

docker save -o output.tar image1 image2 ...

docker load -i input.tar

##This will be the dockerfile after the container is up

FROM docker.registry.com/docker-local/fms/letter:20230403


ENTRYPOINT ["sleep"]
CMD ["10000"]
