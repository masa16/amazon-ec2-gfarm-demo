echo -n "Number of File System Nodes? : "
read n_fsn
echo $n_fsn > N_FSN

cfndsl cfn-tmpl.rb > cfn_template.json

source ./env.sh

aws cloudformation create-stack --region "$region" \
 --stack-name GfarmWsDemo \
 --template-body file://`pwd`/cfn_template.json \
 --parameters ParameterKey=KeyName,ParameterValue="$keyname"

rm -f MdsDnsName
