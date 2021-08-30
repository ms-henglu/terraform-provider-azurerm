
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830083701095613"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "5a08c863-cf68-4ecc-9c50-5f2c379de9d8"
  name               = "acctestrd-210830083701095613"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
