
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603021705748087"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "cf76c176-0217-411a-b164-01f3f2b7a143"
  name               = "acctestrd-220603021705748087"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
