
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-KV-211112020749331637"
  location = "West Europe"
}


resource "azurerm_key_vault_managed_hardware_security_module" "test" {
  name                = "kvHsm211112020749331637"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Standard_B1"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_ids    = [data.azurerm_client_config.current.object_id]
}
