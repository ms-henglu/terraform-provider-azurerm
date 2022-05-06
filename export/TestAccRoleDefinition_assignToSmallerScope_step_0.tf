
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506005425604109"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "417424b1-883b-4a5a-a403-866537006ca9"
  name               = "acctestrd-220506005425604109"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
