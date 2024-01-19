

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025552666203"
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


resource "azurerm_eventhub_namespace" "test" {
  name                = "eventhubtest-240119025552666203"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Production"
  }
}

resource "azurerm_eventhub" "test" {
  name                = "testeventhub-240119025552666203"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_orbital_contact_profile" "test" {
  name                              = "testcontactprofile-240119025552666203"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  minimum_variable_contact_duration = "PT1M"
  auto_tracking                     = "disabled"
  event_hub_uri                     = azurerm_eventhub.test.id
  minimum_elevation_degrees         = 12.12
  links {
    channels {
      name                       = "channelname"
      bandwidth_mhz              = 100
      center_frequency_mhz       = 101
      demodulation_configuration = "na"
      modulation_configuration   = "AQUA_UPLINK_BPSK"
      end_point {
        end_point_name = "AQUA_command"
        ip_address     = "10.0.1.0"
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
