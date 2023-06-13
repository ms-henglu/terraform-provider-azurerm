
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071336753097"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e416811f-b379-4b1f-af07-8611eaca06b0"
  name               = "acctestrd-230613071336753097"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
