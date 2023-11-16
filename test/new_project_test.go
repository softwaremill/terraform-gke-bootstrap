package test

import (
	"testing"
)



func TestNewProject(t *testing.T) {
	t.Parallel()
	testExample(t, "../examples/new-project")
}
