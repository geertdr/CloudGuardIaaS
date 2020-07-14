##########################################
########### Resource Groups  #############
##########################################

# Spoke RG
resource "azurerm_resource_group" "spokes" {
  name     = var.resource_group_name
  location = var.location
}

##########################################
########## Virtual Networks  #############
##########################################

# West vNet
resource "azurerm_virtual_network" "vnet-west" {
  name                = var.west_spoke_name
  address_space       = var.west_spoke_cidr
  location            = var.location
  resource_group_name = var.resource_group_name
}

# East vNet
resource "azurerm_virtual_network" "vnet-east" {
  name                = var.east_spoke_name
  address_space       = var.east_spoke_cidr
  location            = var.location
  resource_group_name = var.resource_group_name
}

##########################################
############# vNet Peering  ##############
##########################################

# Peering West to Hub
resource "azurerm_virtual_network_peering" "west2hub" {
  name                      	= var.peering_west2hub_name
  resource_group_name       	= azurerm_resource_group.spokes.name
  virtual_network_name      	= azurerm_virtual_network.vnet-west.name
  remote_virtual_network_id 	= var.hub_vnet_id
  allow_virtual_network_access	= true
  allow_forwarded_traffic   	= true
}

# Peering East to Hub
resource "azurerm_virtual_network_peering" "east2hub" {
  name                      	= var.peering_east2hub_name
  resource_group_name       	= azurerm_resource_group.spokes.name
  virtual_network_name      	= azurerm_virtual_network.vnet-east.name
  remote_virtual_network_id 	= var.hub_vnet_id
  allow_virtual_network_access	= true
  allow_forwarded_traffic   	= true
}

# Peering Hub to West
resource "azurerm_virtual_network_peering" "hub2west" {
  name                      	= var.peering_hub2west_name
  resource_group_name       	= azurerm_resource_group.spokes.name
  virtual_network_name      	= azurerm_virtual_network.vnet-west.name
  remote_virtual_network_id		= var.hub_vnet_id
  allow_virtual_network_access	= true
  allow_forwarded_traffic   	= true
}

# Peering Hub to East
resource "azurerm_virtual_network_peering" "hub2east" {
  name                      	= var.peering_hub2east_name"
  resource_group_name       	= azurerm_resource_group.spokes.name
  virtual_network_name      	= azurerm_virtual_network.vnet-east.name
  remote_virtual_network_id 	= var.hub_vnet_id
  allow_virtual_network_access	= true
  allow_forwarded_traffic   	= true
}

##########################################
####### Subnets and Route tables #########
##########################################

# Subnet in West
resource "azurerm_subnet" "subnet-west" {
  name                 = var.subnet_west
  resource_group_name  = azurerm_resource_group.spokes.name
  virtual_network_name = azurerm_virtual_network.vnet-west.name
  address_prefix       = "${cidrsubnet(var.west_cidr, 8, 2)}"
}

# Subnet in East
resource "azurerm_subnet" "subnet-east" {
  name                 = var.subnet_east
  resource_group_name  = azurerm_resource_group.spokes.name
  virtual_network_name = azurerm_virtual_network.vnet-east.name
  address_prefix       = "${cidrsubnet(var.east_cidr, 8, 2)}"
}

# Route table for subnet in West
resource "azurerm_route_table" "rt1" {
  name							= "rtWest"
  location						= var.location
  resource_group_name			= azurerm_resource_group.spokes.name
  disable_bgp_route_propagation	= true

  route {
    name						= "to-Internet"
    address_prefix				= "0.0.0.0/0"
    next_hop_type				= "VirtualAppliance"
    next_hop_in_ip_address		= "${cidrhost(azurerm_subnet.sub4.address_prefix, 4)}"
  }
  route {
    name						= "to-internal-current-vnet"
    address_prefix				= "${element(azurerm_virtual_network.vn1.address_space, 0)}"
    next_hop_type				= "VirtualAppliance"
    next_hop_in_ip_address		= "${cidrhost(azurerm_subnet.sub4.address_prefix, 4)}"
  }
  route {
    name						= "to-internal-other-vnet"
    address_prefix				= "${element(azurerm_virtual_network.vnet-west.address_space, 0)}"
    next_hop_type				= "VirtualAppliance"
    next_hop_in_ip_address		= "${cidrhost(azurerm_subnet.sub4.address_prefix, 4)}"
  }
  route {
    name						= "to-internal-current-subnet"
    address_prefix				= "${azurerm_subnet.sub1.address_prefix}"
    next_hop_type				= "vnetlocal"
  }
}

resource "azurerm_subnet_route_table_association" "rt1sub" {
  subnet_id      = "${azurerm_subnet.sub1.id}"
  route_table_id = "${azurerm_route_table.rt1.id}"
}

# Route table for subnet in West
resource "azurerm_route_table" "rt2" {
  name							= "rtEast"
  location						= var.location
  resource_group_name			= azurerm_resource_group.spokes.name
  disable_bgp_route_propagation	= false

  route {
    name						= "to-internal-current-vnet"
    address_prefix				= "${element(azurerm_virtual_network.vnet-west.address_space, 0)}"
    next_hop_type				= "VirtualAppliance"
    next_hop_in_ip_address		= "${cidrhost(azurerm_subnet.sub4.address_prefix, 4)}"
  }
  route {
    name						= "to-internal-other-vnet"
    address_prefix				= "${element(azurerm_virtual_network.vn1.address_space, 0)}"
    next_hop_type				= "VirtualAppliance"
    next_hop_in_ip_address		= "${cidrhost(azurerm_subnet.sub4.address_prefix, 4)}"
  }
  route {
    name						= "to-internal-current-subnet"
    address_prefix				= "${azurerm_subnet.sub2.address_prefix}"
    next_hop_type				= "vnetlocal"
  }
}

resource "azurerm_subnet_route_table_association" "rt2sub" {
  subnet_id      = "${azurerm_subnet.sub2.id}"
  route_table_id = "${azurerm_route_table.rt2.id}"
}
