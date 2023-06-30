
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-cdn-afdx-230630032802148086"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-fdprofile-230630032802148086"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_rule_set" "test" {
  name                     = "acctestfdruleset23063086"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}
