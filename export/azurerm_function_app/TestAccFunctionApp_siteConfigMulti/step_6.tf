
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072748728747"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsargawg"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-231218072748728747"
  location            = azurerm_resource_group.test.location
  kind                = "Linux"
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }

  reserved = true
}

resource "azurerm_function_app" "test" {
  name                       = "acctest-231218072748728747-func"
  location                   = azurerm_resource_group.test.location
  version                    = "~2"
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  os_type                    = "linux"

  app_settings = {
    "hello" = "world"
  }

  site_config {
    always_on        = true
    linux_fx_version = "DOCKER|golang:latest"
  }
}
