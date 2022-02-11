package backupinstances

type PolicyInfo struct {
	PolicyId         string            `json:"policyId"`
	PolicyParameters *PolicyParameters `json:"policyParameters,omitempty"`
	PolicyVersion    *string           `json:"policyVersion,omitempty"`
}
