
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-211105035548669650"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-211105035548669650"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Basic"

  tags = {
    "hello" = "world"
  }
}
