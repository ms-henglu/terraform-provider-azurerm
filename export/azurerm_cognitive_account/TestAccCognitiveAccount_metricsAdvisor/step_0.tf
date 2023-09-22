
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230922060727403825"
  location = "West Europe"
}
resource "azurerm_cognitive_account" "test" {
  name                            = "acctestcogacc-230922060727403825"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  kind                            = "MetricsAdvisor"
  sku_name                        = "S0"
  custom_subdomain_name           = "acctestcogacc-230922060727403825"
  metrics_advisor_aad_client_id   = "310d7b2e-d1d1-4b87-9807-5b885b290c00"
  metrics_advisor_aad_tenant_id   = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  metrics_advisor_super_user_name = "mock_user1"
  metrics_advisor_website_name    = "mock_name2"
}
