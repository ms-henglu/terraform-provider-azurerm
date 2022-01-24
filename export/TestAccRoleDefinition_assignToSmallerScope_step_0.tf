
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124124733956272"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "fbeefbb8-6ff7-411c-a0fb-a42c952bb9cb"
  name               = "acctestrd-220124124733956272"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
