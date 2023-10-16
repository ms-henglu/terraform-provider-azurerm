
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034713714890"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccz09dv"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  location            = azurerm_resource_group.test.location
  name                = "testserviceplanz09dv"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "P1v2"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "test" {
  location            = azurerm_resource_group.test.location
  name                = "testlinuxwebappz09dv"
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {}

  lifecycle {
    ignore_changes = [
      app_settings["AZURE_STORAGEBLOB_RESOURCEENDPOINT"],
      identity,
      sticky_settings,
    ]
  }
}

resource "azurerm_app_service_connection" "test" {
  name               = "acctestserviceconnector231016034713714890"
  app_service_id     = azurerm_linux_web_app.test.id
  target_resource_id = azurerm_storage_account.test.id
  authentication {
    type = "systemAssignedIdentity"
  }
}
