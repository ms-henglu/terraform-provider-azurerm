


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-231020040519626806"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-231020040519626806"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAr1+OxOJw/Ed0SMGvctNRUHDGaCU5UGowpm+Ubo8iWBTjr36ZM4HU9JuNkiWLeQtmwQOLFkpIZjyzg5gyUOyAr9d7wEzss5hvUl5YIRO62Y/AynNLTWXEVf4lQvzsTpDwOh4XDaKWLMN522Bt/skQk00wrqA7JQKkiDOxnANdkhLlH1tEM0Ms2m07KlpMMEhIK5WaFWUVBVx8QhGC14/2dg9Rd+ptuxaA/HTr4h3bPbiWZTnkgHLr8engMac2UxG7SktbSd3oS2a9F38U+UHssyW+4XXDEVdtEevW4dvmHsAX8MAqxjmJYyX34Su4EqgeWmoHEIhpsd2XCRxSS1Lo1Q2kwmzfGn8Z95pbjp1Ir8EKtK0p2cfJhxhU7zg1FeN9Qn9/c8qMby21/jSoy7NOue5gHqRqg7d/fcnLgIeu4XUmlEBplVLrsjJ0Kt2yls6QT9stBjtris2kHvxcj5EBEnh6vWB/7fDDORtKOVKCPV0AmmL5fJcuSkgoGe/d+VvCHkaxQgXHxPmHZQ1fF/AEkgI9ue1rO2lUgnuaHULsKAqpy8kkzERgCOtSPJGBPM1upe/1q0glzhQAoA14De3UCnXjzWYEj47i9eeklDCMPqqqm1F/T+heaz83qpWDg1YEnuHrVue6ysGOR6In+3QM3IxkKVDgrbl3pXo16CHoPwECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
