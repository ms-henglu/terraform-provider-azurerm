
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825042600400010"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  role_definition_id = "ddf8cbb5-8744-4272-bf23-17219e4f3b7a"
  name               = "acctestrd-210825042600400010"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id
  ]
}
