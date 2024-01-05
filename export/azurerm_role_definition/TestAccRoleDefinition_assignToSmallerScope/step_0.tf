
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063311291071"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "4f8e3301-cef5-441c-aef9-1bbbc6aa2243"
  name               = "acctestrd-240105063311291071"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
