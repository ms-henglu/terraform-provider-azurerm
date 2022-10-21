
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021033808822947"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "9b47635a-b556-4e0e-a7d8-0898dbb014c4"
  name               = "acctestrd-221021033808822947"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
