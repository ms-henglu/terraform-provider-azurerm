
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211013071742662649"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2211013071742662649"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211013071742662649"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
}
