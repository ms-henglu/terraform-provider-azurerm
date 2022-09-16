
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011112705685"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "66ad8f3f-6625-431c-979e-8632f920f19a"
  name               = "acctestrd-220916011112705685"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
