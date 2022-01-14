
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114013909036179"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "5eb6fb1a-990a-4d10-a0d8-c3947556e354"
  name               = "acctestrd-220114013909036179"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
