package backuppolicies

import (
	"encoding/json"
	"fmt"
)

var _ BasePolicyRule = AzureRetentionRule{}

type AzureRetentionRule struct {
	IsDefault  *bool             `json:"isDefault,omitempty"`
	Lifecycles []SourceLifeCycle `json:"lifecycles"`

	// Fields inherited from BasePolicyRule
	Name string `json:"name"`
}

var _ json.Marshaler = AzureRetentionRule{}

func (s AzureRetentionRule) MarshalJSON() ([]byte, error) {
	type wrapper AzureRetentionRule
	wrapped := wrapper(s)
	encoded, err := json.Marshal(wrapped)
	if err != nil {
		return nil, fmt.Errorf("marshaling AzureRetentionRule: %+v", err)
	}

	var decoded map[string]interface{}
	if err := json.Unmarshal(encoded, &decoded); err != nil {
		return nil, fmt.Errorf("unmarshaling AzureRetentionRule: %+v", err)
	}
	decoded["objectType"] = "AzureRetentionRule"

	encoded, err = json.Marshal(decoded)
	if err != nil {
		return nil, fmt.Errorf("re-marshaling AzureRetentionRule: %+v", err)
	}

	return encoded, nil
}
