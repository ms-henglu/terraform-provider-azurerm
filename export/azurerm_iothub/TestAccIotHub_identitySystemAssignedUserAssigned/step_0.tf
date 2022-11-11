
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-221111020618286300"
  location = "West Europe"
}
resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-221111020618286300"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-221111020618286300"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku {
    name     = "B1"
    capacity = "1"
  }
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
  tags = {
    purpose = "testing"
  }
}
