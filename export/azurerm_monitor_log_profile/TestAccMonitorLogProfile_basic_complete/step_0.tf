
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423998566"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsasmw6r"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctestehns-smw6r"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 2
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-240119025423998566"

  categories = [
    "Action",
    "Delete",
    "Write",
  ]

  locations = [
    "West Europe",
    "West US 2",
  ]

  # RootManageSharedAccessKey is created by default with listen, send, manage permissions
  servicebus_rule_id = "${azurerm_eventhub_namespace.test.id}/authorizationrules/RootManageSharedAccessKey"
  storage_account_id = azurerm_storage_account.test.id

  retention_policy {
    enabled = true
    days    = 7
  }
}
