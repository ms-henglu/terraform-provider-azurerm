
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903058900"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF240119024903058900"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    git_url            = "https://github.com/hashicorp/"
    repository_name    = "terraform-provider-azurerm"
    branch_name        = "main"
    root_folder        = "/"
    account_name       = "acctestGH-240119024903058900"
    publishing_enabled = false
  }
}
