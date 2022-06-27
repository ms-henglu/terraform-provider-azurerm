
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627134233378275"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "18b339f5-3489-47d2-8009-2fc7e01d3af2"
  name               = "acctestrd-220627134233378275"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
