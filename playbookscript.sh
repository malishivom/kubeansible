ansible-playbook -i ~/kube-cluster/hosts ~/kube-cluster/kube-dependencies.yml
ansible-playbook -i ~/kube-cluster/hosts ~/kube-cluster/master.yml
ansible-playbook -i ~/kube-cluster/hosts ~/kube-cluster/workers.yml

export masterip=$(awk 'NR==1' server.txt)
ssh root@$masterip "echo 'root' | passwd --stdin centos"
sshpass -p root ssh centos@$masterip "kubectl get nodes"