
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326010132475176"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "f2ae4a1c-9c14-4ee8-86ed-760e1f367b9c"
  name               = "acctestrd-220326010132475176"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
