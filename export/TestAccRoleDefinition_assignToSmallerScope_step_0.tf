
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506015545369815"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "c628b572-c490-4d36-b747-90fd49e13cbd"
  name               = "acctestrd-220506015545369815"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
