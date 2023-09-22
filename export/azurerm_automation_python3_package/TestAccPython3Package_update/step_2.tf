


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230922060636395622"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-230922060636395622"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_python3_package" "test" {
  name                    = "acctest-230922060636395622"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  content_uri             = "https://pypi.org/packages/source/r/requests/requests-2.31.0.tar.gz"
  content_version         = "2.31.0"
  hash_algorithm          = "sha256"
  hash_value              = "942c5a758f98d790eaed1a29cb6eefc7ffb0d1cf7af05c3d2791656dbd6ad1e1"
  tags = {
    key = "bar"
  }
}
