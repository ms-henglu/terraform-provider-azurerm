
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122824873532"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfv2240315122824873532"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name            = "acctest240315122824873532"
  data_factory_id = azurerm_data_factory.test.id
  variables = {
    "bob" = "item1"
  }
  activities_json = <<JSON
[
  {
    "name": "test webactivity",
    "type": "WebActivity",
    "dependsOn": [],
    "userProperties": [],
    "typeProperties": {
    
    }
  }
]
JSON
}
