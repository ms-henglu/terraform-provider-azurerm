
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240315122824878831"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF240315122824878831"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    git_url            = "https://github.com/hashicorp/"
    repository_name    = "terraform-provider-azuread"
    branch_name        = "stable-website"
    root_folder        = "/azuread"
    account_name       = "acctestGitHub-240315122824878831"
    publishing_enabled = true
  }
}
