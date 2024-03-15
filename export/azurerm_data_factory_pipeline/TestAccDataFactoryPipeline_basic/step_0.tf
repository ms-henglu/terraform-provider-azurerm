
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240315122824879911"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2240315122824879911"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest240315122824879911"
  data_factory_id = azurerm_data_factory.test.id
}
