
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230414020856373714"
  location = "West US"
}

resource "azurerm_cognitive_account" "test" {
  name                 = "acctestcogacc-230414020856373714"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  kind                 = "QnAMaker"
  qna_runtime_endpoint = "https://localhost:8080/"
  sku_name             = "S0"
}
