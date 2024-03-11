
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240311031853910234"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF240311031853910234"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    repository_name    = "terraform-provider-azurerm"
    branch_name        = "main"
    root_folder        = "/"
    account_name       = "acctestGH-240311031853910234"
    publishing_enabled = false
  }
}
