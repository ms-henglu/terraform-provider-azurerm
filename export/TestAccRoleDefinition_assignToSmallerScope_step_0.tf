
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627123839757274"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "064dff8a-9a5d-4730-b0d5-1c7a52ebd454"
  name               = "acctestrd-220627123839757274"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
