package pm4

import (
	"encoding/json"
	"errors"
	"fmt"
	"html/template"
	"io/fs"
	"path/filepath"
	"strings"

	"github.com/pelletier/go-toml"
)

type any = interface{}

type TemplateConfig struct {
	ThemeDir              string              `toml:"-"`
	TemplateFiles         []string            `toml:"template_files"`
	DataFiles             []string            `toml:"data_files"`
	DataQueries           map[string]string   `toml:"data_queries"`
	DataFunctions         map[string]string   `toml:"data_functions"`
	ContentSecurityPolicy map[string][]string `toml:"content_security_policy"`
}

type TemplateBundle struct {
	TemplateConfig
	Template *template.Template
	Data     map[string]any
}

type TemplateFS struct {
	fsys   fs.FS
	assets fs.FS
}

func NewTemplateFS(fsys, assets fs.FS) *TemplateFS {
	return &TemplateFS{fsys: fsys, assets: assets}
}

func (tmplfs *TemplateFS) asset(data map[string]any, filename string) (string, error) {
	// TODO: themeDir is assumed to be on unix system, must make it work for
	// windows system as well (filepath.Join will produce backslash delimited
	// paths, which we do not want to use in the URL)
	themeDir, _ := data["ThemeDir"].(string)
	path := filepath.Join(themeDir, filename)
	if tmplfs.assets != nil {
		_, err := fs.Stat(tmplfs.assets, strings.TrimLeft(path, "/"))
		if err != nil && !errors.Is(err, fs.ErrNotExist) {
			return "", fmt.Errorf("stat-ing %s in assets: %w", strings.TrimLeft(themeDir, "/"), err)
		} else if err == nil {
			return filepath.Join("/pm-media", path), nil
		}
	}
	return path, nil
}

func (tmplfs *TemplateFS) parseTemplates(themeDir, filename string, filenames ...string) (*template.Template, error) {
	b, err := fs.ReadFile(tmplfs.fsys, filename)
	if err != nil {
		return nil, fmt.Errorf("reading %s: %w", filename, err)
	}
	tmpl, err := template.
		New(filename).
		Funcs(template.FuncMap{"asset": tmplfs.asset}).
		Parse(string(b))
	if err != nil {
		return nil, fmt.Errorf("parsing %s: %w", filename, err)
	}
	for _, name := range filenames {
		b, err = fs.ReadFile(tmplfs.fsys, filepath.Join(themeDir, name))
		if err != nil {
			return nil, fmt.Errorf("reading %s: %w", filepath.Join(themeDir, name), err)
		}
		_, err = tmpl.New(name).Parse(string(b))
		if err != nil {
			return nil, fmt.Errorf("parsing %s: %w", filepath.Join(themeDir, name), err)
		}
	}
	return tmpl, nil
}

func (tmplfs *TemplateFS) getThemeDir(filename string) string {
	path := filename
	for path != filepath.Dir(path) {
		path = filepath.Dir(path)
		_, err := fs.Stat(tmplfs.fsys, filepath.Join(path, "theme.toml"))
		if err != nil {
			continue
		}
		return path
	}
	return ""
}

func (tmplfs *TemplateFS) GetTemplateBundle(filename string) (TemplateBundle, error) {
	tmplBundle := TemplateBundle{Data: make(map[string]any)}
	_, err := fs.Stat(tmplfs.fsys, filename)
	if err != nil {
		return tmplBundle, fmt.Errorf("stat-ing %s: %w", filename, err)
	}
	tmplBundle.ThemeDir = tmplfs.getThemeDir(filename)
	ext := filepath.Ext(filename)
	configFilename := filename[:len(filename)-len(ext)] + ".config.toml"
	b, err := fs.ReadFile(tmplfs.fsys, configFilename)
	if errors.Is(err, fs.ErrNotExist) {
		tmplBundle.Template, err = tmplfs.parseTemplates(tmplBundle.ThemeDir, filename)
		if err != nil {
			return tmplBundle, err
		}
		return tmplBundle, nil
	}
	if err != nil {
		return tmplBundle, fmt.Errorf("reading %s: %w", configFilename, err)
	}
	err = toml.Unmarshal(b, &tmplBundle.TemplateConfig)
	if err != nil {
		return tmplBundle, fmt.Errorf("parsing %s: %w", configFilename, err)
	}
	tmplBundle.Template, err = tmplfs.parseTemplates(tmplBundle.ThemeDir, filename, tmplBundle.TemplateFiles...)
	if err != nil {
		return tmplBundle, err
	}
	for _, dataFile := range tmplBundle.DataFiles {
		b, err = fs.ReadFile(tmplfs.fsys, filepath.Join(tmplBundle.ThemeDir, dataFile))
		if err != nil {
			return tmplBundle, fmt.Errorf("reading %s: %w", filepath.Join(tmplBundle.ThemeDir, dataFile), err)
		}
		m := make(map[string]any)
		err = json.Unmarshal(b, &m)
		if err != nil {
			return tmplBundle, fmt.Errorf("unmarshalling %s: %w", filepath.Join(tmplBundle.ThemeDir, dataFile), err)
		}
		for k, v := range m {
			tmplBundle.Data[k] = v
		}
	}
	tmplBundle.Data["ThemeDir"] = filepath.Join("/pm-templates", tmplBundle.ThemeDir)
	tmplBundle.Data["ContentSecurityPolicy"] = tmplBundle.ContentSecurityPolicy
	return tmplBundle, nil
}
