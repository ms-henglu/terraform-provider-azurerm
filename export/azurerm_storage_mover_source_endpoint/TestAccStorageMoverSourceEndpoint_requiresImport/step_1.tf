



provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231218072652807404"
  location = "West Europe"
}
resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-231218072652807404"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_storage_mover_source_endpoint" "test" {
  name             = "acctest-smse-231218072652807404"
  storage_mover_id = azurerm_storage_mover.test.id
  host             = "192.168.0.1"
}


resource "azurerm_storage_mover_source_endpoint" "import" {
  name             = azurerm_storage_mover_source_endpoint.test.name
  storage_mover_id = azurerm_storage_mover.test.id
  host             = azurerm_storage_mover_source_endpoint.test.host
}
