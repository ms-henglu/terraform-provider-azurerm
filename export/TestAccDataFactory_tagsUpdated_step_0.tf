
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211217035149955066"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211217035149955066"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
