

provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-KV-230825024721337813"
  location = "West Europe"
}


resource "azurerm_key_vault_managed_hardware_security_module" "test" {
  name                     = "kvHsm230825024721337813"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "Standard_B1"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  admin_object_ids         = [data.azurerm_client_config.current.object_id]
  purge_protection_enabled = false
}


resource "azurerm_key_vault_managed_hardware_security_module" "import" {
  name                = azurerm_key_vault_managed_hardware_security_module.test.name
  resource_group_name = azurerm_key_vault_managed_hardware_security_module.test.resource_group_name
  location            = azurerm_key_vault_managed_hardware_security_module.test.location
  sku_name            = azurerm_key_vault_managed_hardware_security_module.test.sku_name
  tenant_id           = azurerm_key_vault_managed_hardware_security_module.test.tenant_id
  admin_object_ids    = azurerm_key_vault_managed_hardware_security_module.test.admin_object_ids
}
