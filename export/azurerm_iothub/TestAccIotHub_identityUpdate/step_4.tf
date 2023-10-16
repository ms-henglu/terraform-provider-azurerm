
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-231016034057267197"
  location = "West Europe"
}
resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-231016034057267197"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-231016034057267197"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku {
    name     = "B1"
    capacity = "1"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
  tags = {
    purpose = "testing"
  }
}
