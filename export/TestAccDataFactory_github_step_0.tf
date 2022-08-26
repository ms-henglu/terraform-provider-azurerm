
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220826005823026465"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220826005823026465"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  github_configuration {
    git_url         = "https://github.com/hashicorp/"
    repository_name = "terraform-provider-azurerm"
    branch_name     = "main"
    root_folder     = "/"
    account_name    = "acctestGH-220826005823026465"
  }
}
