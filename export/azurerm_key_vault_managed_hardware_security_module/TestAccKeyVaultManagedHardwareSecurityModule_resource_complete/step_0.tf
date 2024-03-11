
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-KV-240311032511530173"
  location = "West Europe"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240311032511530173"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test_a" {
  name                 = "acctestsubneta240311032511530173"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_key_vault_managed_hardware_security_module" "test" {
  name                       = "kvHsm240311032511530173"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  sku_name                   = "Standard_B1"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  admin_object_ids           = [data.azurerm_client_config.current.object_id]

  network_acls {
    default_action = "Deny"
    bypass         = "None"
  }

  public_network_access_enabled = true

  tags = {
    Env = "Test"
  }
}
