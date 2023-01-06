
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230106031348174094"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2230106031348174094"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest230106031348174094"
  data_factory_id = azurerm_data_factory.test.id
}
