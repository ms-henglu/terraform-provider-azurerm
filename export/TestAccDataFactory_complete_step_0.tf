
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220311032341963046"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220311032341963046"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
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
