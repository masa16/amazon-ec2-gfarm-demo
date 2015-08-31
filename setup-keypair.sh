source ./env.sh
set -v

# generating ssh keypair
if [ ! -f "$HOME/.ssh/$prikey_file" ]; then
  ssh-keygen -C "$key_name" -f "$HOME/.ssh/$prikey_file"
fi

# import keypair to aws
aws ec2 import-key-pair --region "$region" --key-name "$key_name" --public-key-material "$(cat $HOME/.ssh/$pubkey_file)"
