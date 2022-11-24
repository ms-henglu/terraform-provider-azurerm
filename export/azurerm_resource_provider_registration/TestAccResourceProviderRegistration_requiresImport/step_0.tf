
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_resource_provider_registration" "test" {
  name = "Microsoft.Marketplace"
  lifecycle {
    ignore_changes = [feature]
  }
}
