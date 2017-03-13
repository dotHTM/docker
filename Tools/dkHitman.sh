#!/bin/bash
# dkFullReset.sh

echo "== Containers =="
for i in $(docker ps --all -q); do
	docker rm -f $i
done

echo "== Images =="
for i in $(docker images --all -q); do
	docker rmi -f $i
done

echo "== Volumes =="
for i in $(docker volume ls -q); do
	docker volume rm $i
done

