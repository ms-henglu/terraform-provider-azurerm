
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906021951929092"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e27391b7-fec5-4d72-81e3-5d425a2a6964"
  name               = "acctestrd-210906021951929092"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
