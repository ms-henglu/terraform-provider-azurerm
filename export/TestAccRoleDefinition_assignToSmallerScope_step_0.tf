
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520040349859323"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "6c6ce60a-82d7-407e-9a88-e42c926a38de"
  name               = "acctestrd-220520040349859323"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
