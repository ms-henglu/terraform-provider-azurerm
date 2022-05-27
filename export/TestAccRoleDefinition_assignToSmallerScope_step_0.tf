
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527033831537278"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "3032b70d-2737-4a2a-88a8-094d1940dce7"
  name               = "acctestrd-220527033831537278"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
