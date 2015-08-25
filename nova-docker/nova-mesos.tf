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
  cidr = "192.168.199.0/24"
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
  name = "messos-master"
  image_id ="443befb6-9d0b-409c-9387-5753538fc170"
  flavor_id = "34af1383-3836-4815-8060-503bc5d1b61b"
  security_groups = ["default"]
  region = "RegionOne"
  network {
    uuid = "${openstack_networking_network_v2.mesos-cluster.id}"
  }
}


#resource "openstack_compute_instance_v2" "marathon" {
#  name = "marathon"
#  image_id ="aba691b5-2f76-4565-80d4-37807b55de7f"
#  flavor_id = "1"
#  security_groups = ["default"]
#  region = "RegionOne"
#  network {
#    uuid = "${openstack_networking_network_v2.mesos-cluster.id}"
#  }
#  metadata {
#    master = "${openstack_compute_instance_v2.messos-master.access_ip_v4}"
#  }
#}

resource "openstack_compute_instance_v2" "messos-slave" {
  name = "messos-slave"
  image_id ="af8a06dc-c357-4bad-8290-b0d8f8ab1c07"
  flavor_id = "34af1383-3836-4815-8060-503bc5d1b61b"
  security_groups = ["default"]
  region = "RegionOne"
  count = 3
  network {
    uuid = "${openstack_networking_network_v2.mesos-cluster.id}"
  }
  metadata {
    master = "${openstack_compute_instance_v2.messos-master.access_ip_v4}"
  }
}
