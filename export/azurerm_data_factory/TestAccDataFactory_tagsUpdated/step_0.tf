
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230414021155447396"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230414021155447396"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
