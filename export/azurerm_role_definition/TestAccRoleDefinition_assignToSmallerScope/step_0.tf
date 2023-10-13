
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042942894046"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "79e2cf5d-ba31-459e-bf3e-b3e485dd2941"
  name               = "acctestrd-231013042942894046"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
