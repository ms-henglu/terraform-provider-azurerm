package backupinstances

type ProtectionStatusDetails struct {
	ErrorDetails *UserFacingError `json:"errorDetails,omitempty"`
	Status       *Status          `json:"status,omitempty"`
}
