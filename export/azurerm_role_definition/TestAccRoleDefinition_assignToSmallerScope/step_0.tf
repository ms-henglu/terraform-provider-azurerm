
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013111075525"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "3a170709-a68d-44cf-bf33-311b5f236b60"
  name               = "acctestrd-221216013111075525"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
