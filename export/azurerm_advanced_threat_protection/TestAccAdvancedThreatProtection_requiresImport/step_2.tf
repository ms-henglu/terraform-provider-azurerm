

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ATP-230120052646288819"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestec6f3"
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


resource "azurerm_advanced_threat_protection" "import" {
  target_resource_id = azurerm_advanced_threat_protection.test.target_resource_id
  enabled            = azurerm_advanced_threat_protection.test.enabled
}
