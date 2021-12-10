
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211210024512760256"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211210024512760256"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
