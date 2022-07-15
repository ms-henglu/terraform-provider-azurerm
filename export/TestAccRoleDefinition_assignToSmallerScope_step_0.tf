
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004138342379"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "d84d9a44-1af6-4d67-ae07-dd558b78e747"
  name               = "acctestrd-220715004138342379"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
