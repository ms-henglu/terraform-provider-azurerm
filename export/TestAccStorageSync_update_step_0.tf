
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ss-211013072438571012"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-SS-211013072438571012"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    ENV = "Test"
  }
}
