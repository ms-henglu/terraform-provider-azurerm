
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ss-220527034746878197"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-SS-220527034746878197"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    ENV = "Test"
  }
}
