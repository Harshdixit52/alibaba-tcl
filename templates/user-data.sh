#!/bin/bash

# Alibaba Cloud ECS config
{
  echo "ECS_CLUSTER=${cluster_name}"
} >> /etc/ecs/ecs.config

# Start ECS agent
systemctl start ecs

echo "Done"
