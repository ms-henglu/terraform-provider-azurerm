


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-240105060232705092"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-240105060232705092"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAyP3cwVcemV2hX0uS6gYogOhNNRPqpo1un/oaPNMiR/Odlx7hDymOghi7A01uRsDM7C9Qk7K1jsIy2dk+6kYC4QVXWDd5ukDsC30l6khGLSKxUfCkuiOy/JgMpnMHXBDCeRVaX6jwjLDUTPS+y/Qrj40u43Xdv1roPvIpSRLUXhhQXBKYlFBq3vEMrBlPuRg0QuEPguJKGSdcG7rhF/m62LXsA5kMEWODkGLEiofZZ4dfvj2AghMmmn6ZQJiFxQ721UOUF/lUtfsb9DD9Dk8NvGScqJElk385YtniMUZCMn2MeswmqQ6OeEbXwEKW6u8lUyXRfQr3zezgO/Gac4wIxQBqJlQFPnCVLVBBgqL5s5MWl7vihNZkz7s0t76NRaCgro7ff35XkWh1H4zaVR/GiNIDrNNs5Uol+0PtxxZc8b3FE2ISYvFE/Sa5Wh7i4F70A4otyqIl6no+Fzmv2reu1NM5h+MXzgu9IhF9qkRht6weq8ntHKWSy2sHx2jPS8kWFL20p4Y6cJIG2naVx+dsulhle3Q0OVLegmjqCPxhFheZTtHhqA5nVOPgyEowJY1qxnjWwrcRqfSuFHKtb/0CPpgvEfPwSpPmTvW3wy5C9UQjdc4EA1ZNsIF9uxmOOwd4YEdjDVepJvpBwrAan+31952RnirC8aqcQnB5Lnr2EA0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
