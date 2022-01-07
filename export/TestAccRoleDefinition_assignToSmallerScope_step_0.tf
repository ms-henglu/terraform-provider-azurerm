
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107033546828025"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "251649b5-253d-40e0-bca9-a2c26cb2c98d"
  name               = "acctestrd-220107033546828025"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
