
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124121744658613"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "30af2ec5-bfae-4bcb-969f-bc20114b4ec8"
  name               = "acctestrd-220124121744658613"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
