fsn_ids=`aws ec2 describe-instances --filter 'Name=tag:ServerType,Values=FSN' --query 'Reservations[].Instances[].[InstanceId]' --output text`
echo "> stopping FSN instances:" $fsn_ids
aws ec2 stop-instances --instance-ids $fsn_ids
exit

sleep 10

mds_ids=`aws ec2 describe-instances --filter 'Name=tag:ServerType,Values=MDS' --query 'Reservations[].Instances[].[InstanceId]' --output text`
echo "> stopping MDS instances: $mds_ids"
aws ec2 stop-instances --instance-ids "$mds_ids"
