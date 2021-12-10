
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024512765059"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2211210024512765059"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211210024512765059"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  variables = {
    "bob" = "item1"
  }
  activities_json = <<JSON
[
  {
    "name": "Append variable1",
    "type": "AppendVariable",
    "dependsOn": [],
    "userProperties": [],
    "typeProperties": {
      "variableName": "bob",
      "value": "something"
    }
  }
]
JSON
}
