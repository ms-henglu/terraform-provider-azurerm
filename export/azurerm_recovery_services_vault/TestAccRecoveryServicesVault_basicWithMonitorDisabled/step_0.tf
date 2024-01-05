
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-240105064457634805"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-Vault-240105064457634805"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  monitoring {
    alerts_for_all_job_failures_enabled            = false
    alerts_for_critical_operation_failures_enabled = false
  }

  soft_delete_enabled = false
}
