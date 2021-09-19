package pm4

import (
	"bytes"
	"context"
	"database/sql"
	"embed"
	"errors"
	"flag"
	"fmt"
	htemplate "html/template"
	"io/fs"
	"net/http"
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
)

var (
	flagData        = flag.String("pm-data", "", "")
	flagSecretsFile = flag.String("pm-secrets-file", "", "")
	flagSecretsEnv  = flag.Bool("pm-secrets-env", false, "")
)

type Secrets struct {
	DSN         string
	AssetsDir   string
	S3AccessID  string
	S3SecretKey string
}

func NewSecrets(secretsFile string, secretsEnv bool) (Secrets, error) {
	var secrets Secrets
	if secretsFile != "" {
	} else if secretsEnv {
	}
	return secrets, nil
}

type TemplateConfig struct {
	TemplateFiles         []string            `toml:"template_files"`
	DataFiles             []string            `toml:"data_files"`
	ContentSecurityPolicy map[string][]string `toml:"content_security_policy"`
}

func GetTemplate(fsys fs.FS, name string) (tmpl *htemplate.Template, dataFiles []string, data map[string]interface{}, err error) {
	// oh no. But {{ resolve }} templatefunc needs to be able to check the assetsdir for the corresponding asset when serving the css/js file
	return nil, nil, nil, nil
}

// TemplateFS { templates, assets fs.FS }

// Open(name string) (fs.File, error)

// GetTemplate(name string) (tmpl *template.Template, dataFiles []string, data map[string]interface{}, err error)

// oh no, but the user may need the list of templates files to figure out whether there is a corresponding *.data.js file -- better for GetTemplate to just return an entire struct object that contains the config (plus it can be easily cached)

// Pagemanager { templateFS TemplateFS; dialect string; db *sql.DB }

// any kind of smart caching should be done on the Pagemanager level. It can even activate caching depending on site load (avg is after median)

// MultisitePagemanager

// the reason Pagemanager is sticking to SQL is because template *.data.js files potentially need to run SQL queries. If people want to use a 'scalable' datastore like DynamoDB they can write their own pagemanager implementation that uses TemplateFS

// ServeStats(http.Handler) http.Handler

// ServeAssets(http.Handler) http.Handler

// PageCMS(http.Handler) http.Handler

// ServePages(http.Handler) http.Handler

type Pagemanager struct {
	datadir     fs.FS
	templatedir fs.FS
	assetsdir   fs.FS
	plugins     map[string]http.Handler
}

type Page struct {
	URL          string
	Alias        sql.NullString
	TemplateFile sql.NullString
	PluginID     sql.NullString
	RedirectURL  sql.NullString
}

type DataStore interface {
	SetData(ctx context.Context, dataID string, data []byte) error
	GetData(ctx context.Context, dataIDs ...string) (data []byte, err error)
}

// PageReader needs: PageGetter, TemplateDir, DataGetter
// PageWriter needs: PageSetter, DataSetter

func New() (Pagemanager, error) {
	if !flag.Parsed() { // the presence of this makes New susecptible to race conditions, it is no longer goroutine safe. what if I make the user pass in a parseFlags boolean argument? Then the user invokes it like this New(!flag.Parsed())
		flag.Parse()
	}
	var err error
	var secrets Secrets
	pm := Pagemanager{}
	if *flagSecretsFile != "" {
		b, err := os.ReadFile(*flagSecretsFile)
		if err != nil {
			return pm, fmt.Errorf("reading %s: %w", *flagSecretsFile, err)
		}
		env, err := godotenv.Parse(bytes.NewReader(b))
		if err != nil {
			return pm, fmt.Errorf("parsing %s: %w", *flagSecretsFile, err)
		}
		secrets.DSN = env["DSN"]
		secrets.AssetsDir = env["ASSETS_DIR"]
		secrets.S3AccessID = env["S3_ACCESS_ID"]
		secrets.S3SecretKey = env["S3_SECRET_KEY"]
	} else if *flagSecretsEnv {
		secrets.DSN = os.Getenv("DSN")
		secrets.AssetsDir = os.Getenv("ASSETS_DIR")
		secrets.S3AccessID = os.Getenv("S3_ACCESS_ID")
		secrets.S3SecretKey = os.Getenv("S3_SECRET_KEY")
	}
	datadir := *flagData
	if datadir == "" {
		datadir, err = os.UserHomeDir()
		if err != nil {
			return pm, err
		}
		datadir = filepath.Join(datadir, "pm-data")
	}
	_, err = os.Stat(datadir)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			err = os.MkdirAll(datadir, 0755)
			if err != nil {
				return pm, fmt.Errorf("creating %s: %w", datadir, err)
			}
			err = os.MkdirAll(filepath.Join(datadir, "pm-templates"), 0755)
			if err != nil {
				return pm, fmt.Errorf("creating %s: %w", filepath.Join(datadir, "pm-templates"), err)
			}
		} else {
			return pm, err
		}
	}
	fmt.Printf("-pm-data: %v\n", *flagData)
	fmt.Printf("-pm-secrets-file: %v\n", *flagSecretsFile)
	fmt.Printf("-pm-secrets-env: %v\n", *flagSecretsEnv)
	return pm, nil
	// pm-data -> pm-templates pm-assets
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
