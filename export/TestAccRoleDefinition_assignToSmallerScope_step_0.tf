
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826005522653092"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "0a000153-202c-48c6-9665-a59966c1b11a"
  name               = "acctestrd-220826005522653092"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
