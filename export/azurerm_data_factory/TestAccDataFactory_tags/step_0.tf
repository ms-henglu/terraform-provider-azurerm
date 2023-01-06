
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230106034355709066"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230106034355709066"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
