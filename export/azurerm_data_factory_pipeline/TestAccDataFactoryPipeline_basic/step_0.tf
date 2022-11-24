
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221124181538951125"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2221124181538951125"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest221124181538951125"
  data_factory_id = azurerm_data_factory.test.id
}
