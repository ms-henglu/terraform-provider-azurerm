

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230428050401811608"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230428050401811608"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_purview_account" "import" {
  name                = azurerm_purview_account.test.name
  resource_group_name = azurerm_purview_account.test.resource_group_name
  location            = azurerm_purview_account.test.location

  identity {
    type = "SystemAssigned"
  }
}
