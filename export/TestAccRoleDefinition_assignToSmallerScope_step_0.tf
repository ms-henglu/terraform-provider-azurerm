
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422024806996791"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "a5b8fb2b-e4f0-4af9-8a1c-2553cf13b59a"
  name               = "acctestrd-220422024806996791"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
