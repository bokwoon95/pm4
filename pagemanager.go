package pm4

import (
	"errors"
	"fmt"
	"io/fs"
	"path/filepath"
)

type TemplateFS struct {
	fsys   fs.FS
	assets fs.FS
}

func (tmplFS TemplateFS) Open(name string) (fs.File, error) {
	assetsName := filepath.Join("pm-templates", name)
	file, err := tmplFS.assets.Open(assetsName)
	if err != nil && !errors.Is(err, fs.ErrNotExist) {
		return nil, fmt.Errorf("opening %s: %w", assetsName, err)
	} else if err == nil {
		return file, nil
	}
	return tmplFS.fsys.Open(name)
}
