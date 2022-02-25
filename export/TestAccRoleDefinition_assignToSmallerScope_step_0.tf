
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034038992440"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "aaeeabb1-7832-4356-9faf-630bb72a4049"
  name               = "acctestrd-220225034038992440"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
