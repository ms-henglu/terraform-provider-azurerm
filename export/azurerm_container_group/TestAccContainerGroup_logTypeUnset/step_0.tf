
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033638132629"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016033638132629"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-231016033638132629"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "0.5"
    ports {
      port = 80
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.test.workspace_id
      workspace_key = azurerm_log_analytics_workspace.test.primary_shared_key
    }
  }

  tags = {
    environment = "Testing"
  }
}
