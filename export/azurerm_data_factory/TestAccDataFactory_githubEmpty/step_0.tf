
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240315122824877678"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF240315122824877678"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    repository_name    = "terraform-provider-azurerm"
    branch_name        = "main"
    root_folder        = "/"
    account_name       = "acctestGH-240315122824877678"
    publishing_enabled = false
  }
}
