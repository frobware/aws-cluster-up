# Procedure to update autoscaler with new ASG/LC

This procedure assumes you have created the new ASG/LC ahead of time.
The procedure captures the commands that allow you to safely upgrade
the ASG in use, but also migrates the current workload safely.

- Verify current auto scale groups

```bash
aws autoscaling describe-auto-scaling-groups --region us-east-1 --query 'AutoScalingGroups[].[AutoScalingGroupName,MinSize,MaxSize,DesiredCapacity,LaunchConfigurationName]' --output table
```

- Setup environment variables used throughout this example:

```bash
CUR_ASG_NAME=amcdermo-asg311-ASG-0
NEW_ASG_NAME=amcdermo-asg311-ASG-1
```

- Scale down the autoscaler deployment so that no new further autoscaling takes place:

```bash
kubectl scale deployment -n openshift-autoscaler --replicas=0 cluster-autoscaler
```

- Find all instances in existing ASG

```bash
instances=$(aws autoscaling describe-auto-scaling-instances --no-paginate --region us-east-1 --query="AutoScalingInstances[?AutoScalingGroupName=='$CUR_ASG_NAME'].InstanceId" --output text)
```

- Map instances to nodes

```bash
nodes=$(aws ec2 describe-instances --instance-ids ${instances:?error: zero instances in $CUR_ASG_NAME} --region us-east-1 --query Reservations[].Instances[].PrivateDnsName --output text)
```

- Cordon nodes to prevent any further scheduling

```bash
for i in $nodes; do oc adm cordon $i; done
```

- Bump the capacity of the new ASG - this could be set to the min/max of the old ASG + some headroom. **Must** wait until new nodes become `Ready`.

```bash
aws autoscaling update-auto-scaling-group --auto-scaling-group-name $NEW_ASG_NAME --min-size 3 --desired-capacity 3
```

- Drain the existing nodes. PODs will migrate onto the new compute nodes.

You may want to add a `sleep` after N nodes are drained (i.e., make
the procedure batched) so that the existing workload has time to start
afresh on the new node.

```bash
for i in $nodes; do oc adm drain $i --delete-local-data=true --ignore-daemonsets=true; done
```

- Once all PODs have migrated we can delete all the old nodes by scaling the outgoing ASG to 0

```bash
aws autoscaling update-auto-scaling-group --auto-scaling-group-name $CUR_ASG_NAME --min-size 0 --max-size 0 --desired-capacity 0
```

- Update the cluster-autoscaler to reference the new ASG/LC

```bash
kubectl edit deployment -n openshift-autoscaler cluster-autoscaler
```

And replace the line that has the old ASG with the new ASG:
`- --nodes=0:10:amcdermo-asg311-ASG-0` with:
`- --nodes=0:10:amcdermo-asg311-ASG-1`

- Scale autoscaler deployment back up

```bash
kubectl scale deployment -n openshift-autoscaler --replicas=1 cluster-autoscaler
```

- Reset min/max for ongoing autoscaling

```bash
aws autoscaling update-auto-scaling-group --auto-scaling-group-name $NEW_ASG_NAME --min-size 0 --max-size 10
```
