
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759708822"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF231016033759708822"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
