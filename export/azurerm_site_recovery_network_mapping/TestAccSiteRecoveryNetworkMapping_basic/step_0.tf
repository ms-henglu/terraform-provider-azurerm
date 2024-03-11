
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-240311032938283773-1"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-240311032938283773"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_fabric" "test1" {
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name
  name                = "acctest-fabric1-240311032938283773"
  location            = azurerm_resource_group.test.location
}

resource "azurerm_site_recovery_fabric" "test2" {
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name
  name                = "acctest-fabric2-240311032938283773"
  location            = "West US 2"
  depends_on          = [azurerm_site_recovery_fabric.test1]
}

resource "azurerm_virtual_network" "test1" {
  name                = "network1-240311032938283773"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_site_recovery_fabric.test1.location
}

resource "azurerm_virtual_network" "test2" {
  name                = "network2-240311032938283773"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.2.0/24"]
  location            = azurerm_site_recovery_fabric.test2.location
}

resource "azurerm_site_recovery_network_mapping" "test" {
  resource_group_name         = azurerm_resource_group.test.name
  recovery_vault_name         = azurerm_recovery_services_vault.test.name
  name                        = "mapping-240311032938283773"
  source_recovery_fabric_name = azurerm_site_recovery_fabric.test1.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.test2.name
  source_network_id           = azurerm_virtual_network.test1.id
  target_network_id           = azurerm_virtual_network.test2.id
}
