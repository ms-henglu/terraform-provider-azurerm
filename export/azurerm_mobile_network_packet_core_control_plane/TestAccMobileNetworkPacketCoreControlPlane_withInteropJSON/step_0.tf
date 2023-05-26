
				

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230526085512580133"
  location = "eastus"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230526085512580133"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_site" "test" {
  name              = "acctest-mns-230526085512580133"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_mobile_network.test.location
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acct230526085512580133"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"
}



resource "azurerm_mobile_network_packet_core_control_plane" "test" {
  name                              = "acctest-mnpccp-230526085512580133"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = "eastus"
  sku                               = "G0"
  site_ids                          = [azurerm_mobile_network_site.test.id]
  control_plane_access_name         = "default-interface"
  control_plane_access_ipv4_address = "192.168.1.199"
  control_plane_access_ipv4_gateway = "192.168.1.1"
  control_plane_access_ipv4_subnet  = "192.168.1.0/25"

  local_diagnostics_access {
    authentication_type = "AAD"
  }

  platform {
    type           = "AKS-HCI"
    edge_device_id = azurerm_databox_edge_device.test.id
  }

  interoperability_settings_json = jsonencode({
    "mtu" = 1440
  })

  depends_on = [azurerm_mobile_network.test]
}
