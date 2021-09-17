
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917031343529301"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e8a9545b-cdd2-4527-af93-9fb5f12c7d2a"
  name               = "acctestrd-210917031343529301"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
