
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240315122824877404"
  location = "West Europe"
}

resource "azurerm_purview_account" "test" {
  name                = "acctestaccu8ttd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF240315122824877404"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  purview_id          = azurerm_purview_account.test.id

  vsts_configuration {
    account_name       = "test account name"
    branch_name        = "test branch name"
    project_name       = "test project name"
    repository_name    = "test repository name"
    root_folder        = "/"
    tenant_id          = "00000000-0000-0000-0000-000000000000"
    publishing_enabled = false
  }

  tags = {
    environment = "production"
  }
}
