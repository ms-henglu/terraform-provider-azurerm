
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217074912323867"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "05916d91-b199-4db1-8fb7-cf9ecb37ce59"
  name               = "acctestrd-211217074912323867"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
