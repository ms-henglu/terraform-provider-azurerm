
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-231016033620609386"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016033620609386"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctoeykd"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "accTest"
  }
}

resource "azurerm_storage_share" "test" {
  name                 = "testshareoeykd"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv231016033620609386"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}



resource "azurerm_container_app_environment_storage" "test" {
  name                         = "testacc-caes-231016033620609386"
  container_app_environment_id = azurerm_container_app_environment.test.id
  account_name                 = azurerm_storage_account.test.name
  access_key                   = azurerm_storage_account.test.secondary_access_key
  share_name                   = azurerm_storage_share.test.name
  access_mode                  = "ReadOnly"
}
