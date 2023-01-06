
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031129888919"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "66828cdc-16d8-49af-9309-ba1c4865f62d"
  name               = "acctestrd-230106031129888919"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
