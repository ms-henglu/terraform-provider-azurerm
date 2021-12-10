
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210034347750203"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "b2b7329e-3eff-470d-bba9-8ec10b222a04"
  name               = "acctestrd-211210034347750203"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
