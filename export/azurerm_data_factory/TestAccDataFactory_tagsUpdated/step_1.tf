
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230324051947451443"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230324051947451443"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
    updated     = "true"
  }
}
