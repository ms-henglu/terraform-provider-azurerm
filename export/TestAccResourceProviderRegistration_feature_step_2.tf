
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_resource_provider_registration" "test" {
  name = "Microsoft.HybridCompute"
  feature {
    name       = "UpdateCenter"
    registered = true
  }
  feature {
    name       = "ArcServerPrivateLinkPreview"
    registered = false
  }
}
