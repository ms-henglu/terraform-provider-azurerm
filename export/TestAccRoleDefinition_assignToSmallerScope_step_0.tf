
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065156052633"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4c92b618-811a-4178-aa36-fda963ac8c7a"
  name               = "acctestrd-220429065156052633"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
