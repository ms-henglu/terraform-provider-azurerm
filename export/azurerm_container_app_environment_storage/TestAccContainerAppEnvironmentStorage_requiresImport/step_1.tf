

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-231016033620604378"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016033620604378"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctmukgq"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "accTest"
  }
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharemukgq"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv231016033620604378"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}



resource "azurerm_container_app_environment_storage" "test" {
  name                         = "testacc-caes-231016033620604378"
  container_app_environment_id = azurerm_container_app_environment.test.id
  account_name                 = azurerm_storage_account.test.name
  access_key                   = azurerm_storage_account.test.primary_access_key
  share_name                   = azurerm_storage_share.test.name
  access_mode                  = "ReadWrite"
}


resource "azurerm_container_app_environment_storage" "import" {
  name                         = azurerm_container_app_environment_storage.test.name
  container_app_environment_id = azurerm_container_app_environment_storage.test.container_app_environment_id
  account_name                 = azurerm_container_app_environment_storage.test.account_name
  access_key                   = azurerm_container_app_environment_storage.test.access_key
  share_name                   = azurerm_container_app_environment_storage.test.share_name
  access_mode                  = azurerm_container_app_environment_storage.test.access_mode
}
