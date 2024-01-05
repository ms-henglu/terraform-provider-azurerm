
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-240105061150591893"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-240105061150591893"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  mobile_country_code = "001"
  mobile_network_code = "01"
}

resource "azurerm_mobile_network_slice" "test" {
  name              = "acctest-mns-240105061150591893"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = "West Europe"
  single_network_slice_selection_assistance_information {
    slice_service_type = 1
  }
}


resource "azurerm_mobile_network_service" "test" {
  name               = "acctest-mns-240105061150591893"
  mobile_network_id  = azurerm_mobile_network.test.id
  location           = "West Europe"
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

resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mndn-240105061150591893"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = "West Europe"
}


resource "azurerm_mobile_network_sim_policy" "test" {
  name                                   = "acctest-mnsp-240105061150591893"
  mobile_network_id                      = azurerm_mobile_network.test.id
  location                               = azurerm_mobile_network.test.location
  default_slice_id                       = azurerm_mobile_network_slice.test.id
  registration_timer_in_seconds          = 3240
  rat_frequency_selection_priority_index = 1

  slice {
    default_data_network_id = azurerm_mobile_network_data_network.test.id
    slice_id                = azurerm_mobile_network_slice.test.id
    data_network {
      allocation_and_retention_priority_level = 9
      default_session_type                    = "IPv4"
      qos_indicator                           = 9
      preemption_capability                   = "NotPreempt"
      preemption_vulnerability                = "Preemptable"
      allowed_services_ids                    = [azurerm_mobile_network_service.test.id]
      data_network_id                         = azurerm_mobile_network_data_network.test.id
      max_buffered_packets                    = 200
      session_aggregate_maximum_bit_rate {
        downlink = "1 Gbps"
        uplink   = "500 Mbps"
      }
    }
  }

  user_equipment_aggregate_maximum_bit_rate {
    downlink = "1 Gbps"
    uplink   = "500 Mbps"
  }
  tags = {
    key = "value"
  }

}
