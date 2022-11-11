
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020015215122"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "f831ffc3-a422-4980-8c75-2ef13a0bb63c"
  name               = "acctestrd-221111020015215122"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
