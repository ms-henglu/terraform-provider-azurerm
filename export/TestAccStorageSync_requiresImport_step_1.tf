

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ss-220715004939700274"
  location = "West Europe"
}

resource "azurerm_storage_sync" "test" {
  name                = "acctest-SS-220715004939700274"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    ENV = "Test"
  }
}


resource "azurerm_storage_sync" "import" {
  name                = azurerm_storage_sync.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
