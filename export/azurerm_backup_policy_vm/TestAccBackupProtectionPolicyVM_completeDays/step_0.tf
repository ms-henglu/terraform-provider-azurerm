

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-backup-230915024052081596"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-230915024052081596"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}


resource "azurerm_backup_policy_vm" "test" {
  name                = "acctest-230915024052081596"
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_monthly {
    count             = 10
    days              = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    include_last_days = true
  }

  retention_yearly {
    count             = 10
    months            = ["January", "July"]
    days              = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    include_last_days = true
  }

}
