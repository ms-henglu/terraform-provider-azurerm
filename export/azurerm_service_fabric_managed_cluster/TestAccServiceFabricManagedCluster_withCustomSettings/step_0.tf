
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sfmc-240105061546541580"
  location = "West Europe"
}

resource "azurerm_service_fabric_managed_cluster" "test" {
  name                = "testacc-sfmc-v3xih"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  username            = "testUser"
  password            = "NotV3ryS3cur3P@$$w0rd"
  dns_service_enabled = true

  client_connection_port = 12345
  http_gateway_port      = 23456

  lb_rule {
    backend_port       = 8000
    frontend_port      = 443
    probe_protocol     = "http"
    protocol           = "tcp"
    probe_request_path = "/"
  }

  custom_fabric_setting {
    section   = "ClusterManager"
    parameter = "EnableDefaultServicesUpgrade"
    value     = true
  }

  
node_type {
  data_disk_size_gb      = 130
  name                   = "test1"
  primary                = true
  application_port_range = "7000-9000"
  ephemeral_port_range   = "10000-20000"

  vm_size            = "Standard_DS2_v2"
  vm_image_publisher = "MicrosoftWindowsServer"
  vm_image_sku       = "2016-Datacenter"
  vm_image_offer     = "WindowsServer"
  vm_image_version   = "latest"
  vm_instance_count  = 5
}


  tags = {
    Test = "value"
  }
}
