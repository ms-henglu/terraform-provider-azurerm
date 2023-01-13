
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230113181015482809"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230113181015482809"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
    updated     = "true"
  }
}
