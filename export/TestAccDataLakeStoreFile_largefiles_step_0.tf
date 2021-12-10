
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211210034559703721"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "unlikely23exst2acctgevo3"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  firewall_state      = "Disabled"
}

resource "azurerm_data_lake_store_file" "test" {
  remote_file_path = "/test/testAccAzureRMDataLakeStoreFile_largefiles.bin"
  account_name     = azurerm_data_lake_store.test.name
  local_file_path  = "/tmp/azurerm-acc-datalake-file-large638431573"
}
