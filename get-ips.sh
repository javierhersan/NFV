# Ejecutar desde k8s en /shared/NFV

sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient_h11
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient_h12
#sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient_h21
#sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x dhclient_h22

sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x retrieve_ip_h11 | grep 192.168.255
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x retrieve_ip_h12 | grep 192.168.255
#sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x retrieve_ip_h21 | grep 192.168.255
#sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -x retrieve_ip_h22 | grep 192.168.255
