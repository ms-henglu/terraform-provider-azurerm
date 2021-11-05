

provider "azurerm" {
  features {}
}

provider "azuread" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211105035818299548"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-DSA-211105035818299548"
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
  name       = "acctest_DS_211105035818299548"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestdlsbmejv"
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
  name               = "acctest-DSDL1-211105035818299548"
  data_share_id      = azurerm_data_share.test.id
  data_lake_store_id = azurerm_data_lake_store.test.id
  folder_path        = "test"
  depends_on = [
    azurerm_role_assignment.test,
  ]
}
