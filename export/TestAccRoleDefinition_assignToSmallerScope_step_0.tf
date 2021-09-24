
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924010706686308"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d3341673-5e04-400f-8545-2074c9a8c00c"
  name               = "acctestrd-210924010706686308"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
