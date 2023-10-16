
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759706517"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2231016033759706517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest231016033759706517"
  data_factory_id = azurerm_data_factory.test.id
}
