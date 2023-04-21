
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230421022033997798"
  location = "West Europe"
}

resource "azurerm_purview_account" "test" {
  name                = "acctestaccgd3yd"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230421022033997798"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  purview_id          = azurerm_purview_account.test.id

  vsts_configuration {
    account_name    = "test account name"
    branch_name     = "test branch name"
    project_name    = "test project name"
    repository_name = "test repository name"
    root_folder     = "/"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
  }

  tags = {
    environment = "production"
  }
}
