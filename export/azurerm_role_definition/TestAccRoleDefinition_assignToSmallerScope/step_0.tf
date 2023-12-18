
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071242944035"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "256ddfc9-09d0-4a9d-a8c8-29eb6d267481"
  name               = "acctestrd-231218071242944035"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
