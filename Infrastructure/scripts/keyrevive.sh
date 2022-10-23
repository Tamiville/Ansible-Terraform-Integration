#!/bin/bash
exec >>(tee /var/log/nginx.log) 2>&1

path="{path_privatekey}"

if [[ -f $path == "ansiblekey2"]]
then 
   echo "Key is present"
else
   echo "lost key, but retriving key using ssh key scan method"
   ssh-keyscan ${vmip} >> /root/.ssh/known_hosts
fi