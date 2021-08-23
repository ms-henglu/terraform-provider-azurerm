package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-provider-azurerm/helpers/azure"
)

type NetworkUserRuleCollectionId struct {
	SubscriptionId                string
	ResourceGroup                 string
	NetworkManagerName            string
	SecurityUserConfigurationName string
	RuleCollectionName            string
}

func NewNetworkUserRuleCollectionID(subscriptionId, resourceGroup, networkManagerName, securityUserConfigurationName, ruleCollectionName string) NetworkUserRuleCollectionId {
	return NetworkUserRuleCollectionId{
		SubscriptionId:                subscriptionId,
		ResourceGroup:                 resourceGroup,
		NetworkManagerName:            networkManagerName,
		SecurityUserConfigurationName: securityUserConfigurationName,
		RuleCollectionName:            ruleCollectionName,
	}
}

func (id NetworkUserRuleCollectionId) String() string {
	segments := []string{
		fmt.Sprintf("Rule Collection Name %q", id.RuleCollectionName),
		fmt.Sprintf("Security User Configuration Name %q", id.SecurityUserConfigurationName),
		fmt.Sprintf("Network Manager Name %q", id.NetworkManagerName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Network User Rule Collection", segmentsStr)
}

func (id NetworkUserRuleCollectionId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkManagers/%s/securityUserConfigurations/%s/ruleCollections/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName, id.SecurityUserConfigurationName, id.RuleCollectionName)
}

// NetworkUserRuleCollectionID parses a NetworkUserRuleCollection ID into an NetworkUserRuleCollectionId struct
func NetworkUserRuleCollectionID(input string) (*NetworkUserRuleCollectionId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := NetworkUserRuleCollectionId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.NetworkManagerName, err = id.PopSegment("networkManagers"); err != nil {
		return nil, err
	}
	if resourceId.SecurityUserConfigurationName, err = id.PopSegment("securityUserConfigurations"); err != nil {
		return nil, err
	}
	if resourceId.RuleCollectionName, err = id.PopSegment("ruleCollections"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
