


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240105060313957599"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240105060313957599"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_python3_package" "test" {
  name                    = "acctest-240105060313957599"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  content_uri             = "https://pypi.org/packages/source/r/requests/requests-2.31.0.tar.gz"
  content_version         = "2.31.0"
  tags = {
    key = "foo"
  }
}
