
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030145043054"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "0f358dec-d96a-4341-a847-f1ed0731be4b"
  name               = "acctestrd-220415030145043054"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
