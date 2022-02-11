
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220211130449484235"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220211130449484235"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
