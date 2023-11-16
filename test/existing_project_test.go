package test

import (
	"testing"
)

func TestExistingProject(t *testing.T) {
	t.Parallel()
	testExample(t, "../examples/existing-project")
}
