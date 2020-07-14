variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}

variable "west_spoke_name" {
  description = "Name of West Spoke Virtual Network"
  type = string
  default     = "VNET-WEST"
}

variable "east_spoke_name" {
  description = "Name of East Spoke Virtual Network"
  type = string
  default     = "VNET-EAST"
}

variable "west_spoke_cidr" {
  description = "The address prefixes of the virtual network"
  type = string
  default     = "10.1.1.0/24"
}

variable "east_spoke_cidr" {
  description = "The address prefixes of the virtual network"
  type = string
  default     = "10.1.2.0/24"
}

variable "peering_west2hub_name" {
  description = "Name of West Spoke to Hub peering"
  type = string
  default     = "west2hub"
}

variable "peering_east2hub_name" {
  description = "Name of East Spoke to Hub peering"
  type = string
  default     = "east2hub"
}

variable "peering_hub2west_name" {
  description = "Name of Hub to West Spoke peering"
  type = string
  default     = "hub2west"
}

variable "peering_hub2east_name" {
  description = "Name of Hub to East Spoke peering"
  type = string
  default     = "hub2east"
}

variable "hub_vnet_id" {
  description = "Hub id"
  type = string
}
