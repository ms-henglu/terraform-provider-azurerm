
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527023846045657"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "58d2447b-f521-4fa2-a8c1-148b32c7c5fa"
  name               = "acctestrd-220527023846045657"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
