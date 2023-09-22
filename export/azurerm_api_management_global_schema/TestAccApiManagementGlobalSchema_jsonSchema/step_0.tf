
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060507043895"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230922060507043895"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_global_schema" "test" {
  schema_id           = "accetestSchema-230922060507043895"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  type                = "json"
  value               = <<JSON
{
    "schema-bug-example": {
        "properties": {
            "Field2": {
                "description": "Field2",
                "type": "string"
            },
            "field1": {
                "description": "Field1",
                "type": "string"
            }
        },
        "required": [
            "field1",
            "Field2"
        ],
        "type": "object"
    }
}
JSON
}
