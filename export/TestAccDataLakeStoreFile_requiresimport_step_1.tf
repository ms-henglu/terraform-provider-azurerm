

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220211043507754806"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "unlikely23exst2accttqjrx"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  firewall_state      = "Disabled"
}

resource "azurerm_data_lake_store_file" "test" {
  remote_file_path = "/test/application_gateway_test.cer"
  account_name     = azurerm_data_lake_store.test.name
  local_file_path  = "./testdata/application_gateway_test.cer"
}


resource "azurerm_data_lake_store_file" "import" {
  remote_file_path = azurerm_data_lake_store_file.test.remote_file_path
  account_name     = azurerm_data_lake_store_file.test.account_name
  local_file_path  = "./testdata/application_gateway_test.cer"
}
