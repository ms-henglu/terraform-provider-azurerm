

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021928732226"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccfgt0t"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharefgt0t"
  storage_account_name = azurerm_storage_account.test.name
}
