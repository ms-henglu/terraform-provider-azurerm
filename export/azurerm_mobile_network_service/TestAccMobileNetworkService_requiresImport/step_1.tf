
			
				
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230227175736438644"
  location = "eastus"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230227175736438644"
  resource_group_name = azurerm_resource_group.test.name
  location            = "eastus"
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_service" "test" {
  name               = "acctest-mns-230227175736438644"
  mobile_network_id  = azurerm_mobile_network.test.id
  location           = "eastus"
  service_precedence = 0

  pcc_rule {
    name                    = "default-rule"
    precedence              = 1
    traffic_control_enabled = true

    service_data_flow_template {
      direction      = "Uplink"
      name           = "IP-to-server"
      protocol       = ["ip"]
      remote_ip_list = ["10.3.4.0/24"]
    }

  }
}


resource "azurerm_mobile_network_service" "import" {
  name               = azurerm_mobile_network_service.test.name
  mobile_network_id  = azurerm_mobile_network.test.id
  location           = "eastus"
  service_precedence = 0

  pcc_rule {
    name                    = "default-rule"
    precedence              = 1
    traffic_control_enabled = true

    service_data_flow_template {
      direction      = "Uplink"
      name           = "IP-to-server"
      ports          = []
      protocol       = ["ip"]
      remote_ip_list = ["10.3.4.0/24"]
    }
  }
}
