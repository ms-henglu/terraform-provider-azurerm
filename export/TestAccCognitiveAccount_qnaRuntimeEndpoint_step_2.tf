
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-220610022312685548"
  location = "West US"
}

resource "azurerm_cognitive_account" "test" {
  name                 = "acctestcogacc-220610022312685548"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  kind                 = "QnAMaker"
  qna_runtime_endpoint = "https://localhost:9000/"
  sku_name             = "S0"
}
