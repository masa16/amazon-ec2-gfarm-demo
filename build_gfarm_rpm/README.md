
## copy scripts to AWS instance
```shell
scp gfarm-mds-build-script.sh aws-mds:
scp gfarm-mds-install-script.sh aws-mds:
tar czf - .aws -C ~ | ssh aws-mds tar xvzf -
```

##* build Gfarm RPM
```shell
ssh aws-mds
[ec2-user@ip-10-0-0-10 ~]$ sh gfarm-mds-build-script.sh
[ec2-user@ip-10-0-0-10 ~]$ sudo sh gfarm-mds-install-script.sh
```
