
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211013071742662844"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211013071742662844"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    git_url         = "https://github.com/hashicorp/"
    repository_name = "terraform-provider-azuread"
    branch_name     = "stable-website"
    root_folder     = "/azuread"
    account_name    = "acctestGitHub-211013071742662844"
  }
}
