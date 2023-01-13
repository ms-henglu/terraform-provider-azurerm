
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sfmc-230113181723753432"
  location = "West Europe"
}

resource "azurerm_service_fabric_managed_cluster" "test" {
  name                = "testacc-sfmc-7qstd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  username            = "testUser"
  password            = "NotV3ryS3cur3P@$$w0rd"

  client_connection_port = 12345
  http_gateway_port      = 23456

  lb_rule {
    backend_port       = 8000
    frontend_port      = 443
    probe_protocol     = "http"
    protocol           = "tcp"
    probe_request_path = "/"
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


  authentication {
    certificate {
      thumbprint = "AAAA0982E0241795C04A61168D95B8DEE1B2CCCC"
      type       = "AdminClient"
    }
  }
}
