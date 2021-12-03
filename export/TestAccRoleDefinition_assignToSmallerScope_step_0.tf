
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161046637595"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c38e56d2-8fbf-4ca7-8736-e16d880f4acb"
  name               = "acctestrd-211203161046637595"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
