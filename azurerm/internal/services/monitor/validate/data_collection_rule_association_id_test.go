package validate

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import "testing"

func TestDataCollectionRuleAssociationID(t *testing.T) {
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
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/",
			Valid: false,
		},

		{
			// missing value for ResourceGroup
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/",
			Valid: false,
		},

		{
			// missing VirtualMachineName
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/",
			Valid: false,
		},

		{
			// missing value for VirtualMachineName
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/",
			Valid: false,
		},

		{
			// missing Name
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/",
			Valid: false,
		},

		{
			// missing value for Name
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/dataCollectionRuleAssociations/",
			Valid: false,
		},

		{
			// valid
			Input: "/subscriptions/703362b3-f278-4e4b-9179-c76eaf41ffc2/resourceGroups/group1/providers/Microsoft.Compute/virtualMachines/virtualMachine1/providers/Microsoft.Insights/dataCollectionRuleAssociations/association1",
			Valid: true,
		},

		{
			// upper-cased
			Input: "/SUBSCRIPTIONS/703362B3-F278-4E4B-9179-C76EAF41FFC2/RESOURCEGROUPS/GROUP1/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINES/VIRTUALMACHINE1/PROVIDERS/MICROSOFT.INSIGHTS/DATACOLLECTIONRULEASSOCIATIONS/ASSOCIATION1",
			Valid: false,
		},
	}
	for _, tc := range cases {
		t.Logf("[DEBUG] Testing Value %s", tc.Input)
		_, errors := DataCollectionRuleAssociationID(tc.Input, "test")
		valid := len(errors) == 0

		if tc.Valid != valid {
			t.Fatalf("Expected %t but got %t", tc.Valid, valid)
		}
	}
}
