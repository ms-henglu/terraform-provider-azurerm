
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211001020702335458"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2211001020702335458"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211001020702335458"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  annotations         = ["test1", "test2", "test3"]
  description         = "test description"

  parameters = {
    test = "testparameter"
  }

  variables = {
    foo = "test1"
    bar = "test2"
  }
}
