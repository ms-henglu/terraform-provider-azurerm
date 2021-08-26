
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023102330217"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "709904ea-2943-4514-8cca-38eef29b296e"
  name               = "acctestrd-210826023102330217"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
