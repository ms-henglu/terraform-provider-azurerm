
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221021031111877410"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221021031111877410"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "production"
  }
}
