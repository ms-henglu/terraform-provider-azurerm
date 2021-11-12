
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020237691555"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "014243d3-0672-417a-a277-788aabb781a5"
  name               = "acctestrd-211112020237691555"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
