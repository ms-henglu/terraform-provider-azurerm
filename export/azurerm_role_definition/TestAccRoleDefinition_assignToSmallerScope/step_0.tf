
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021030839510885"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "1133a2d8-8ff1-44e4-bbad-f533045c9b4d"
  name               = "acctestrd-221021030839510885"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
