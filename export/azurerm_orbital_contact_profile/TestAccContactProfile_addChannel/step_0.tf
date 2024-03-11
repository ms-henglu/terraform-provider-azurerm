

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032822541042"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "testvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "testsubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "orbitalgateway"

    service_delegation {
      name = "Microsoft.Orbital/orbitalGateways"
      actions = [
        "Microsoft.Network/publicIPAddresses/join/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/read",
        "Microsoft.Network/publicIPAddresses/read",
      ]
    }
  }
}


resource "azurerm_orbital_contact_profile" "test" {
  name                              = "testcontactprofile-240311032822541042"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  minimum_variable_contact_duration = "PT1M"
  auto_tracking                     = "disabled"
  links {
    channels {
      name                 = "channelname"
      bandwidth_mhz        = 100
      center_frequency_mhz = 101
      end_point {
        end_point_name = "AQUA_command"
        port           = "49513"
        protocol       = "TCP"
      }
    }
    direction    = "Uplink"
    name         = "RHCP_UL"
    polarization = "RHCP"
  }
  network_configuration_subnet_id = azurerm_subnet.test.id
}
