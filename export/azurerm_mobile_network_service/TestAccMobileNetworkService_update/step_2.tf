
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-240112224851831713"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-240112224851831713"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_service" "test" {
  name               = "acctest-mns-240112224851831713"
  mobile_network_id  = azurerm_mobile_network.test.id
  location           = azurerm_mobile_network.test.location
  service_precedence = 0

  pcc_rule {
    name                    = "default-rule-2"
    precedence              = 1
    traffic_control_enabled = false
    qos_policy {
      allocation_and_retention_priority_level = 9
      qos_indicator                           = 9
      preemption_capability                   = "MayPreempt"
      preemption_vulnerability                = "NotPreemptable"
      guaranteed_bit_rate {
        downlink = "200 Mbps"
        uplink   = "20 Mbps"
      }
      maximum_bit_rate {
        downlink = "2 Gbps"
        uplink   = "200 Mbps"
      }
    }

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
      downlink = "2 Gbps"
      uplink   = "200 Mbps"
    }
  }
  tags = {
    key = "update"
  }

}
