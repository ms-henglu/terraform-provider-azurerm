
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-231016034321700183"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-231016034321700183"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_service" "test" {
  name               = "acctest-mns-231016034321700183"
  mobile_network_id  = azurerm_mobile_network.test.id
  location           = azurerm_mobile_network.test.location
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

  service_qos_policy {
    allocation_and_retention_priority_level = 9
    qos_indicator                           = 9
    preemption_capability                   = "NotPreempt"
    preemption_vulnerability                = "Preemptable"
    maximum_bit_rate {
      downlink = "1 Gbps"
      uplink   = "100 Mbps"
    }
  }
}
