
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231218071631612466"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF231218071631612466"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    git_url            = "https://github.com/hashicorp/"
    repository_name    = "terraform-provider-azurerm"
    branch_name        = "main"
    root_folder        = "/"
    account_name       = "acctestGH-231218071631612466"
    publishing_enabled = false
  }
}
