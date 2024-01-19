
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119030025622459"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsak17wz"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240119030025622459"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "test" {
  name                       = "acctest-240119030025622459-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    always_on                 = true
    scm_type                  = "LocalGit"
    use_32_bit_worker_process = false
  }
}
