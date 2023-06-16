
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074256041567"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c42c4f0c-01e1-4827-a79b-706630b5f241"
  name               = "acctestrd-230616074256041567"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
