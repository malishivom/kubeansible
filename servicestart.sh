- hosts: all
  become: yes
  tasks:
	- name: Disable Firewall
      shell: systemctl stop firewalld

    - name: Disable Swap
      shell: swapoff -a
	 
	- name: start kubelet
     service:
       name: kubelet
       enabled: yes
       state: started  