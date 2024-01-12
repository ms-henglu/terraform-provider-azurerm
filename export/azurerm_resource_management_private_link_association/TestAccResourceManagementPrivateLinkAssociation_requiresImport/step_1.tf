

provider "azurerm" {
  features {}
}


data "azurerm_client_config" "test" {}

data "azurerm_management_group" "test" {
  name = data.azurerm_client_config.test.tenant_id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-240112035056390021"
  location = "West Europe"
}

resource "azurerm_resource_management_private_link" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestrmpl-240112035056390021"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_resource_management_private_link_association" "test" {
  name                                = "c4d76d58-857a-f623-3762-43d024a57f48"
  management_group_id                 = data.azurerm_management_group.test.id
  resource_management_private_link_id = azurerm_resource_management_private_link.test.id
  public_network_access_enabled       = true
}


resource "azurerm_resource_management_private_link_association" "import" {
  name                                = azurerm_resource_management_private_link_association.test.name
  management_group_id                 = azurerm_resource_management_private_link_association.test.management_group_id
  resource_management_private_link_id = azurerm_resource_management_private_link_association.test.resource_management_private_link_id
  public_network_access_enabled       = azurerm_resource_management_private_link_association.test.public_network_access_enabled
}
