

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061636395093"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacce14pu"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharee14pu"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 5
}
