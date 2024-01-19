
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024515597328"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "58824abd-6997-4dac-8ee7-b987f9473c26"
  name               = "acctestrd-240119024515597328"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
