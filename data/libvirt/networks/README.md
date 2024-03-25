TODO: Describe networks
virsh net-define foreman_http.xml
virsh net-create ./foreman_http.xml
virsh net-autostart foreman_http
virsh net-start
