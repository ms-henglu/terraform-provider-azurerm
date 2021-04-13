package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"testing"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/resourceid"
)

var _ resourceid.Formatter = NetworkAdminRuleId{}

func TestNetworkAdminRuleIDFormatter(t *testing.T) {
	actual := NewNetworkAdminRuleID("12345678-1234-9876-4563-123456789012", "resGroup1", "networkManager1", "securityConfiguration1", "adminRule1").ID()
	expected := "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/securityConfiguration1/adminRules/adminRule1"
	if actual != expected {
		t.Fatalf("Expected %q but got %q", expected, actual)
	}
}

func TestNetworkAdminRuleID(t *testing.T) {
	testData := []struct {
		Input    string
		Error    bool
		Expected *NetworkAdminRuleId
	}{

		{
			// empty
			Input: "",
			Error: true,
		},

		{
			// missing SubscriptionId
			Input: "/",
			Error: true,
		},

		{
			// missing value for SubscriptionId
			Input: "/subscriptions/",
			Error: true,
		},

		{
			// missing ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/",
			Error: true,
		},

		{
			// missing value for ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/",
			Error: true,
		},

		{
			// missing NetworkManagerName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/",
			Error: true,
		},

		{
			// missing value for NetworkManagerName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/",
			Error: true,
		},

		{
			// missing SecurityConfigurationName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/",
			Error: true,
		},

		{
			// missing value for SecurityConfigurationName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/",
			Error: true,
		},

		{
			// missing AdminRuleName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/securityConfiguration1/",
			Error: true,
		},

		{
			// missing value for AdminRuleName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/securityConfiguration1/adminRules/",
			Error: true,
		},

		{
			// valid
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/securityConfiguration1/adminRules/adminRule1",
			Expected: &NetworkAdminRuleId{
				SubscriptionId:            "12345678-1234-9876-4563-123456789012",
				ResourceGroup:             "resGroup1",
				NetworkManagerName:        "networkManager1",
				SecurityConfigurationName: "securityConfiguration1",
				AdminRuleName:             "adminRule1",
			},
		},

		{
			// upper-cased
			Input: "/SUBSCRIPTIONS/12345678-1234-9876-4563-123456789012/RESOURCEGROUPS/RESGROUP1/PROVIDERS/MICROSOFT.NETWORK/NETWORKMANAGERS/NETWORKMANAGER1/SECURITYCONFIGURATIONS/SECURITYCONFIGURATION1/ADMINRULES/ADMINRULE1",
			Error: true,
		},
	}

	for _, v := range testData {
		t.Logf("[DEBUG] Testing %q", v.Input)

		actual, err := NetworkAdminRuleID(v.Input)
		if err != nil {
			if v.Error {
				continue
			}

			t.Fatalf("Expect a value but got an error: %s", err)
		}
		if v.Error {
			t.Fatal("Expect an error but didn't get one")
		}

		if actual.SubscriptionId != v.Expected.SubscriptionId {
			t.Fatalf("Expected %q but got %q for SubscriptionId", v.Expected.SubscriptionId, actual.SubscriptionId)
		}
		if actual.ResourceGroup != v.Expected.ResourceGroup {
			t.Fatalf("Expected %q but got %q for ResourceGroup", v.Expected.ResourceGroup, actual.ResourceGroup)
		}
		if actual.NetworkManagerName != v.Expected.NetworkManagerName {
			t.Fatalf("Expected %q but got %q for NetworkManagerName", v.Expected.NetworkManagerName, actual.NetworkManagerName)
		}
		if actual.SecurityConfigurationName != v.Expected.SecurityConfigurationName {
			t.Fatalf("Expected %q but got %q for SecurityConfigurationName", v.Expected.SecurityConfigurationName, actual.SecurityConfigurationName)
		}
		if actual.AdminRuleName != v.Expected.AdminRuleName {
			t.Fatalf("Expected %q but got %q for AdminRuleName", v.Expected.AdminRuleName, actual.AdminRuleName)
		}
	}
}
