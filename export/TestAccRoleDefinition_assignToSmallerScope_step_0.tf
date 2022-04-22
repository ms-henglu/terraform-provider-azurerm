
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422011556040959"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "48df8efc-fa4a-4131-93a7-1b5ccdae7f6b"
  name               = "acctestrd-220422011556040959"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
