
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811052859349134"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "f089734b-084e-4d7e-b371-344abb716ea8"
  name               = "acctestrd-220811052859349134"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
