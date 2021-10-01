
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001053448304723"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "b8b22b11-4076-4938-bfb2-29e76c1af258"
  name               = "acctestrd-211001053448304723"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
