
				

				
				

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230915023813908819"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230915023813908819"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_site" "test" {
  name              = "acctest-mns-230915023813908819"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_mobile_network.test.location
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acct230915023813908819"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"
}



resource "azurerm_mobile_network_packet_core_control_plane" "test" {
  name                = "acctest-mnpccp-230915023813908819"
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
  name                                        = "acctest-mnpcdp-230915023813908819"
  mobile_network_packet_core_control_plane_id = azurerm_mobile_network_packet_core_control_plane.test.id
  location                                    = "West Europe"
}


resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mnadn-230915023813908819"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_resource_group.test.location
}



resource "azurerm_mobile_network_attached_data_network" "test" {
  mobile_network_data_network_name         = azurerm_mobile_network_data_network.test.name
  mobile_network_packet_core_data_plane_id = azurerm_mobile_network_packet_core_data_plane.test.id
  location                                 = "West Europe"
  dns_addresses                            = ["1.1.1.1"]
  user_equipment_address_pool_prefixes     = ["2.4.0.0/16"]
}
