
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316221038391952"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "5fd41d3e-2aad-4ca1-be86-dc35d81a1079"
  name               = "acctestrd-230316221038391952"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
