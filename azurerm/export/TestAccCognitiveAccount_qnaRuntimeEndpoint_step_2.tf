
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-220627131649098565"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                 = "acctestcogacc-220627131649098565"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  kind                 = "QnAMaker"
  qna_runtime_endpoint = "https://localhost:9000/"
  sku_name             = "S0"
}
