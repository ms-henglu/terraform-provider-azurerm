
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fwpolicy-RCG-240119024515589682"
  location = "West Europe"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.test.object_id
}
