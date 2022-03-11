
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311032104062669"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "a661cdd1-8565-43e4-ab2a-3011dde3dfbe"
  name               = "acctestrd-220311032104062669"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
