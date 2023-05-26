
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230526084957303463"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2230526084957303463"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest230526084957303463"
  data_factory_id = azurerm_data_factory.test.id
}
