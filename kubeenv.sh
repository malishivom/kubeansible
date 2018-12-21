export DIRECTORY=~/.ssh
echo $DIRECTORY
if [ -d "$DIRECTORY" ]; then
	echo "SSH Directory and Authorised keys is already exist"
else 
	echo -e "\n"|ssh-keygen -t rsa -N ""	
fi
sudo yum install -y sshpass git

echo "In Below Information we need to maintain the IP's of master and worker nodes"
read -p "Enter the Master Node IP : " masterip
sleep 2
read -p "Enter the Worker Nodes IP's with space : " workernode
sleep 2
read -p "Enter the ssh login user : " loginuser
sleep 2
read -p "Enter the ssh password : " password
sleep 2
echo $masterip
echo $workernode
echo $loginuser
echo $password
export loginuser=$loginuser
export password=$password
echo "$masterip" "$workernode" > ipaddress.txt
cat ipaddress.txt
 awk ' { for(i=1;i<=NF;i++)
          { print $i }
        } ' ipaddress.txt > server.txt
cat server.txt
export masterip=$(awk 'NR==1' server.txt)
export slaveip1=$(awk 'NR==2' server.txt)
export slaveip2=$(awk 'NR==3' server.txt)
for server in `cat server.txt`;  
do  
    sshpass -p $password ssh-copy-id -o StrictHostKeyChecking=no $loginuser@$server 
done

sudo yum install -y ansible

echo "In Below Information we need to maintain the Hostname of master and worker nodes"
read -p "Enter the Hostname of Master node of Kube Cluster : " kubemaster
sleep 2
read -p "Enter the Hostname of Worker nodes of kube Cluster with spaces : " kubeworker
sleep 2
echo $kubemaster
echo $kubeworker

echo $kubemaster "$kubeworker" > hostname.txt

awk ' { for(i=1;i<=NF;i++)
          { print $i }
        } ' hostname.txt > hostdns.txt

export masterdns=$(awk 'NR==1' hostdns.txt)
export slavedns1=$(awk 'NR==2' hostdns.txt)
export slavedns2=$(awk 'NR==3' hostdns.txt)

rm -rf ~/hosts
rm -rf ~/kube-cluster
git clone -b kubeansible https://github.com/malishivom/kubeansible.git ~/hosts 
mkdir ~/kube-cluster
cp -rf ~/hosts/hosts ~/kube-cluster/
cp -rf ~/hosts/kube-dependencies.yml ~/kube-cluster/
cp -rf ~/hosts/master.yml ~/kube-cluster/
cp -rf ~/hosts/workers.yml ~/kube-cluster/

sed -ie "s|master|$masterdns|" ~/kube-cluster/hosts
sed -ie "s|slave1|$slavedns1|" ~/kube-cluster/hosts
sed -ie "s|slave2|$slavedns2|" ~/kube-cluster/hosts
sed -ie "s|masip1|$masterip|" ~/kube-cluster/hosts
sed -ie "s|slip1|$slaveip1|" ~/kube-cluster/hosts
sed -ie "s|slip2|$slaveip2|" ~/kube-cluster/hosts
sed -ie "s|userlogin|$loginuser|" ~/kube-cluster/hosts

sed -ie "s|master|$masterdns|" ~/kube-cluster/kube-dependencies.yml
sed -ie "s|masterdns|$masterdns|" ~/kube-cluster/master.yml
sed -ie "s|masterdns|$masterdns|" ~/kube-cluster/workers.yml
echo "This script has succesfully executed"