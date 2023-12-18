
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072636528984"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc7rxxb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_table" "test" {
  name                 = "acctestst231218072636528984"
  storage_account_name = azurerm_storage_account.test.name
}
