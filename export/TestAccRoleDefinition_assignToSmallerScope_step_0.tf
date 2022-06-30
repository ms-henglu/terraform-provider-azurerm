
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630210500349616"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "65347d91-b99f-46f9-99f5-e45dda468b2f"
  name               = "acctestrd-220630210500349616"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
