

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-231020040932843568"
  location = "West Europe"
}


resource "azurerm_data_protection_resource_guard" "test" {
  name                = "acctest-dprg-231020040932843568"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  vault_critical_operation_exclusion_list = ["Microsoft.RecoveryServices/vaults/backupconfig/delete", "Microsoft.RecoveryServices/vaults/backupResourceGuardProxies/write"]

  tags = {
    ENV = "Test1"
  }
}
