

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-220818235059344248"
  location = "West Europe"
}


resource "azurerm_data_protection_resource_guard" "test" {
  name                = "acctest-dprg-220818235059344248"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  vault_critical_operation_exclusion_list = ["Microsoft.RecoveryServices/vaults/backupResourceGuardProxies/write"]

  tags = {
    ENV = "Test2"
  }
}
