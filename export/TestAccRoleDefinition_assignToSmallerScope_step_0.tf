
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020510409533"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4beb9aa7-7618-4c68-ad40-b126b1671c3d"
  name               = "acctestrd-211001020510409533"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
