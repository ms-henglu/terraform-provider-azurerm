
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722051613162708"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "43c33415-5582-4b54-aa34-8bff42d7c761"
  name               = "acctestrd-220722051613162708"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
