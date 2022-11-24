
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ATP-221124182245029131"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestfpd62"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_advanced_threat_protection" "test" {
  target_resource_id = "${azurerm_storage_account.test.id}"
  enabled            = true
}
