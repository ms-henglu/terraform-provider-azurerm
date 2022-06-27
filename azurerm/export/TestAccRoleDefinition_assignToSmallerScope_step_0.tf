
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627125633932692"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "e4c30e7b-26a5-404a-a613-a74caa22ba89"
  name               = "acctestrd-220627125633932692"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
