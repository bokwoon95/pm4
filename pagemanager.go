package pm4

import (
	"context"
	"database/sql"
	"embed"
	"flag"
	"fmt"
	"io/fs"
	"net/http"
)

var (
	flagData        = flag.String("pm-data", "", "")
	flagSecretsFile = flag.String("pm-secrets-file", "", "")
	flagSecretsEnv  = flag.Bool("pm-secrets-env", false, "")
)

type Pagemanager struct {
	datadir     fs.FS
	templatedir fs.FS
	assetsdir   fs.FS
}

type Page struct {
	URL          string
	SiteID       string
	PageType     string
	TemplatePath string
	PluginID     string
	RedirectURL  string
}

var plugins map[string]http.Handler

// Route(*http.Request) (template, plugin string, err error)

type Router interface {
	Route(*http.Request) (Page, error)
}

type TemplateDataStore interface {
	GetData(ctx context.Context, siteID sql.NullString, dataPaths ...string) (data map[string]interface{}, err error)
}

func New() (Pagemanager, error) {
	if !flag.Parsed() {
		flag.Parse()
	}
	fmt.Printf("-pm-data: %v\n", *flagData)
	fmt.Printf("-pm-secrets-file: %v\n", *flagSecretsFile)
	fmt.Printf("-pm-secrets-env: %v\n", *flagSecretsEnv)
	pm := Pagemanager{}
	return pm, nil
}

//go:embed pm-templates
var templatedir embed.FS

func RenderTemplate(templatePath string) (string, error) {
	b, err := fs.ReadFile(templatedir, templatePath)
	if err != nil {
		return "", err
	}
	return string(b), nil
}
