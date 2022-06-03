
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603004543010099"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d4c0e0af-5c7d-47e6-97b6-76919db4e749"
  name               = "acctestrd-220603004543010099"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
