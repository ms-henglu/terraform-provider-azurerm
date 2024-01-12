
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "test" {}

data "azurerm_management_group" "test" {
  name = data.azurerm_client_config.test.tenant_id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-240112035056398220"
  location = "West Europe"
}

resource "azurerm_resource_management_private_link" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestrmpl-240112035056398220"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_resource_management_private_link_association" "test" {
  name                                = "d9fba863-ed99-8ebe-5eb1-9970c17c7c9b"
  management_group_id                 = data.azurerm_management_group.test.id
  resource_management_private_link_id = azurerm_resource_management_private_link.test.id
  public_network_access_enabled       = true
}
