
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223047563940"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4807f11d-5e00-49a9-aab2-5331069dda52"
  name               = "acctestrd-220623223047563940"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
