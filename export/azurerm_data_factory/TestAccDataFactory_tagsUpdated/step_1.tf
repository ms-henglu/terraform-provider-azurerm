
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221221204215465681"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221221204215465681"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
    updated     = "true"
  }
}
