
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040545361801"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4bc14635-6c1b-48ab-b6f9-fe5333d3eb5b"
  name               = "acctestrd-231020040545361801"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
