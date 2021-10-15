

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-backup-211015014659518429"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-211015014659518429"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}


resource "azurerm_backup_policy_file_share" "test" {
  name                = "acctest-211015014659518429"
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }
}
