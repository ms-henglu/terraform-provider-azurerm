package validate

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import "testing"

func TestPrivateEndpointConnectionID(t *testing.T) {
	cases := []struct {
		Input string
		Valid bool
	}{

		{
			// empty
			Input: "",
			Valid: false,
		},

		{
			// missing SubscriptionId
			Input: "/",
			Valid: false,
		},

		{
			// missing value for SubscriptionId
			Input: "/subscriptions/",
			Valid: false,
		},

		{
			// missing ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/",
			Valid: false,
		},

		{
			// missing value for ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/",
			Valid: false,
		},

		{
			// missing AccountName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resourceGroup1/providers/Microsoft.CognitiveServices/",
			Valid: false,
		},

		{
			// missing value for AccountName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resourceGroup1/providers/Microsoft.CognitiveServices/accounts/",
			Valid: false,
		},

		{
			// missing Name
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resourceGroup1/providers/Microsoft.CognitiveServices/accounts/account1/",
			Valid: false,
		},

		{
			// missing value for Name
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resourceGroup1/providers/Microsoft.CognitiveServices/accounts/account1/privateEndpointConnections/",
			Valid: false,
		},

		{
			// valid
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resourceGroup1/providers/Microsoft.CognitiveServices/accounts/account1/privateEndpointConnections/privateEndpointConnection1",
			Valid: true,
		},

		{
			// upper-cased
			Input: "/SUBSCRIPTIONS/12345678-1234-9876-4563-123456789012/RESOURCEGROUPS/RESOURCEGROUP1/PROVIDERS/MICROSOFT.COGNITIVESERVICES/ACCOUNTS/ACCOUNT1/PRIVATEENDPOINTCONNECTIONS/PRIVATEENDPOINTCONNECTION1",
			Valid: false,
		},
	}
	for _, tc := range cases {
		t.Logf("[DEBUG] Testing Value %s", tc.Input)
		_, errors := PrivateEndpointConnectionID(tc.Input, "test")
		valid := len(errors) == 0

		if tc.Valid != valid {
			t.Fatalf("Expected %t but got %t", tc.Valid, valid)
		}
	}
}
