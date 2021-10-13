


provider "azurerm" {
  features {}
}

provider "azuread" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211013071803631185"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-DSA-211013071803631185"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }

  tags = {
    env = "Test"
  }
}

resource "azurerm_data_share" "test" {
  name       = "acctest_DS_211013071803631185"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestdlsdo1sd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  firewall_state      = "Disabled"
}

resource "azurerm_data_lake_store_file" "test" {
  account_name     = azurerm_data_lake_store.test.name
  local_file_path  = "./testdata/application_gateway_test.cer"
  remote_file_path = "/test/application_gateway_test.cer"
}

data "azuread_service_principal" "test" {
  display_name = azurerm_data_share_account.test.name
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_data_lake_store.test.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_service_principal.test.object_id
}


resource "azurerm_data_share_dataset_data_lake_gen1" "test" {
  name               = "acctest-DSDL1-211013071803631185"
  data_share_id      = azurerm_data_share.test.id
  data_lake_store_id = azurerm_data_lake_store.test.id
  file_name          = "application_gateway_test.cer"
  folder_path        = "test"
  depends_on = [
    azurerm_role_assignment.test,
  ]
}

resource "azurerm_data_share_dataset_data_lake_gen1" "import" {
  name               = azurerm_data_share_dataset_data_lake_gen1.test.name
  data_share_id      = azurerm_data_share.test.id
  data_lake_store_id = azurerm_data_share_dataset_data_lake_gen1.test.data_lake_store_id
  folder_path        = azurerm_data_share_dataset_data_lake_gen1.test.folder_path
}
