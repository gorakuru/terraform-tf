provider "openstack" {
    user_name  = "admin"
    tenant_name = "demo"
    password  = "password"
    auth_url  = "http://CONTROLLER-ADDRESS:5000/v2.0"
}


resource "openstack_networking_network_v2" "mesos-cluster" {
  name = "mesos-cluster"
  admin_state_up = "true"
  region = "RegionOne"
}


resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = "${openstack_networking_network_v2.mesos-cluster.id}"
  cidr = "192.168.198.0/24"
  ip_version = 4
}


resource "openstack_networking_router_v2" "rt1" {
  region = "RegionOne"
  name = "rt1"
}


resource "openstack_networking_router_interface_v2" "router_interface_1" {
  region = "RegionOne"
  router_id = "${openstack_networking_router_v2.rt1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}


resource "openstack_compute_instance_v2" "messos-master" {
  name = "master"
  image_id ="518fceda-02bd-4ae6-b82e-6d37c64fcaa0"
  flavor_id = "2"
  security_groups = ["default"]
  region = "RegionOne"
  network {
    uuid = "${openstack_networking_network_v2.mesos-cluster.id}"
  }
}


#  metadata {
#    master = "${openstack_compute_instance_v2.messos-master.access_ip_v4}"
#  }

resource "openstack_compute_instance_v2" "messos-slave" {
  name = "slave"
  image_id ="2ac160fe-d613-4b3f-b03f-bfc0d9d0cfe5"
  flavor_id = "2"
  security_groups = ["default"]
  region = "RegionOne"
  count = 2
  network {
    uuid = "${openstack_networking_network_v2.mesos-cluster.id}"
  }
  provisioner "remote-exec" {
    connection {
      user = "centos"
      key_file = "~/.ssh/mesos.pem.dec"
    }
    inline = [
      "sudo bash start_mesos.sh ${openstack_compute_instance_v2.messos-master.access_ip_v4}"
    ]
  }
}
