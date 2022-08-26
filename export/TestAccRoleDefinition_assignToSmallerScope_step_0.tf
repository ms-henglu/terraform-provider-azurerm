
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002345020112"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "fd78a1f2-f40f-420f-b385-250993446884"
  name               = "acctestrd-220826002345020112"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
