
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010942502945"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccxa4e0"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  location            = azurerm_resource_group.test.location
  name                = "testserviceplanxa4e0"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "P1v2"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "test" {
  location            = azurerm_resource_group.test.location
  name                = "testlinuxwebappxa4e0"
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}

  lifecycle {
    ignore_changes = [
      app_settings["AZURE_STORAGEBLOB_RESOURCEENDPOINT"],
      identity,
    ]
  }
}

resource "azurerm_app_service_connection" "test" {
  name               = "acctestserviceconnector230707010942502945"
  app_service_id     = azurerm_linux_web_app.test.id
  target_resource_id = azurerm_storage_account.test.id
  authentication {
    type = "systemAssignedIdentity"
  }
}
