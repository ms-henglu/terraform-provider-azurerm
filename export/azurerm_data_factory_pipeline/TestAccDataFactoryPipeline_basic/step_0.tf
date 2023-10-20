
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231020040940466913"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2231020040940466913"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest231020040940466913"
  data_factory_id = azurerm_data_factory.test.id
}
