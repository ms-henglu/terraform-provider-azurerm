
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220627131806470383"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220627131806470383"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    git_url         = "https://github.com/terraform-providers/"
    repository_name = "terraform-provider-azurerm"
    branch_name     = "master"
    root_folder     = "/"
    account_name    = "acctestGH-220627131806470383"
  }
}
