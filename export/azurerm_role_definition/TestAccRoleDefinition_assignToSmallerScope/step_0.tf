
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005120480728"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "94e91fd4-3438-46de-ab20-28396bca4321"
  name               = "acctestrd-221104005120480728"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
