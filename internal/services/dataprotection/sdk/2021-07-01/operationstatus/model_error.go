package operationstatus

type Error struct {
	AdditionalInfo *[]ErrorAdditionalInfo `json:"additionalInfo,omitempty"`
	Code           *string                `json:"code,omitempty"`
	Details        *[]Error               `json:"details,omitempty"`
	Message        *string                `json:"message,omitempty"`
	Target         *string                `json:"target,omitempty"`
}
