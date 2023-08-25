

provider "azurerm" {
  features {}
}
locals {
  random_integer   = 230825024843889057
  primary_location = "West Europe"
}
resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${local.random_integer}"
  location = local.primary_location
}

resource "azurerm_user_assigned_identity" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestuai-${local.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_federated_identity_credential" "test" {
  audience            = ["foo"]
  issuer              = "https://foo"
  name                = "acctest-${local.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
  parent_id           = azurerm_user_assigned_identity.test.id
  subject             = "foo"
}
