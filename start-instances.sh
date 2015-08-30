mds_ids=`aws ec2 describe-instances --filter 'Name=tag:ServerType,Values=MDS' --query 'Reservations[].Instances[].[InstanceId]' --output text`
echo "> starting MDS instances: "$mds_ids
aws ec2 start-instances --instance-ids $mds_ids

sleep 10

fsn_ids=`aws ec2 describe-instances --filter 'Name=tag:ServerType,Values=FSN' --query 'Reservations[].Instances[].[InstanceId]' --output text`
echo "> starting FSN instances:" $fsn_ids
aws ec2 start-instances --instance-ids $fsn_ids
