
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220630210719617035"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220630210719617035"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}
