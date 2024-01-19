
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527744814"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-240119025527744814"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240119025527744814"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "test" {
  depends_on          = [azurerm_public_ip.test]
  name                = "acctestvng-240119025527744814"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.test.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test.id
  }

  policy_group {
    name       = "TestPolicyGroup"
    is_default = true
    priority   = 1

    policy_member {
      name  = "TestPolicyMember"
      type  = "RadiusAzureGroupId"
      value = "6ad1bd08"
    }
  }

  vpn_client_configuration {
    address_space        = ["10.2.0.0/24"]
    vpn_client_protocols = ["IkeV2"]

    radius_server_address = "1.2.3.4"
    radius_server_secret  = "1234"

    virtual_network_gateway_client_connection {
      name               = "TestConnection"
      policy_group_names = ["TestPolicyGroup"]
      address_prefixes   = ["10.2.0.0/24"]
    }

    ipsec_policy {
      sa_lifetime_in_seconds    = 300
      sa_data_size_in_kilobytes = 1024
      ipsec_encryption          = "AES256"
      ipsec_integrity           = "SHA256"
      ike_encryption            = "AES128"
      ike_integrity             = "SHA256"
      dh_group                  = "DHGroup14"
      pfs_group                 = "PFS14"
    }
  }
}
