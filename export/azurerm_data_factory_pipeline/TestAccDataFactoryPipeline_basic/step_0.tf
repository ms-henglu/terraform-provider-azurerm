
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230804025818558492"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2230804025818558492"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest230804025818558492"
  data_factory_id = azurerm_data_factory.test.id
}
