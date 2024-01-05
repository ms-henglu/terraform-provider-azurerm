
				

				
				

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-240105061150584913"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-240105061150584913"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_site" "test" {
  name              = "acctest-mns-240105061150584913"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_mobile_network.test.location
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acct240105061150584913"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"
}



resource "azurerm_mobile_network_packet_core_control_plane" "test" {
  name                = "acctest-mnpccp-240105061150584913"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  sku                 = "G0"
  site_ids            = [azurerm_mobile_network_site.test.id]

  local_diagnostics_access {
    authentication_type = "AAD"
  }

  platform {
    type           = "AKS-HCI"
    edge_device_id = azurerm_databox_edge_device.test.id
  }

  depends_on = [azurerm_mobile_network.test]
}


resource "azurerm_mobile_network_packet_core_data_plane" "test" {
  name                                        = "acctest-mnpcdp-240105061150584913"
  mobile_network_packet_core_control_plane_id = azurerm_mobile_network_packet_core_control_plane.test.id
  location                                    = "West Europe"
}


resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mnadn-240105061150584913"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_resource_group.test.location
}



resource "azurerm_mobile_network_attached_data_network" "test" {
  mobile_network_data_network_name         = azurerm_mobile_network_data_network.test.name
  mobile_network_packet_core_data_plane_id = azurerm_mobile_network_packet_core_data_plane.test.id
  location                                 = "West Europe"
  dns_addresses                            = ["1.1.1.1"]
  user_equipment_address_pool_prefixes     = ["2.4.0.0/16"]
  user_plane_access_name                   = "test"
  user_plane_access_ipv4_address           = "10.204.141.4"
  user_plane_access_ipv4_gateway           = "10.204.141.1"
  user_plane_access_ipv4_subnet            = "10.204.141.0/24"
}
