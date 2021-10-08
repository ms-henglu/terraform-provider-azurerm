
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044052024889"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "10913ea0-78d8-4084-9c7f-e8a98447d7ca"
  name               = "acctestrd-211008044052024889"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
