
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211043231262802"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "57ca013c-1d30-4647-9419-99d40920b9b7"
  name               = "acctestrd-220211043231262802"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
