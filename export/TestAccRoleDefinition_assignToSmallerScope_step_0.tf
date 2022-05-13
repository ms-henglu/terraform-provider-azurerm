
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513175933848467"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "cab9fc11-bd50-4514-8311-fc688d9285ef"
  name               = "acctestrd-220513175933848467"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
