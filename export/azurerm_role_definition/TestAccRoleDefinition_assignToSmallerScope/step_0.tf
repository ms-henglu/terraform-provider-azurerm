
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313020731672313"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "ce9abd9e-aed3-4cd8-ac74-64e428bba522"
  name               = "acctestrd-230313020731672313"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
