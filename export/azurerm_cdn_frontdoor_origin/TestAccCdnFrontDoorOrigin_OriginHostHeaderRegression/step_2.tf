
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-cdn-afdx-240105060356325403"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  
  name                = "acctest-cdnfdprofile-240105060356325403"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "test" {
  name                     = "acctest-cdnfd-group-240105060356325403"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}


resource "azurerm_cdn_frontdoor_origin" "test" {
  name                          = "acctest-cdnfdorigin-240105060356325403"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.test.id
  enabled                       = true

  certificate_name_check_enabled = false
  host_name                      = "contoso.com"
  origin_host_header             = "regression20866.australiaeast.cloudapp.azure.com"
  http_port                      = 80
  https_port                     = 443
  priority                       = 5
  weight                         = 1
}
