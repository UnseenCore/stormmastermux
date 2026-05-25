package config

import (
	"os"

	"github.com/pelletier/go-toml/v2"
)

type Config struct {
	Server struct {
		UDPListen   string `toml:"udp_listen"`
		TCPListen   string `toml:"tcp_listen"`
		ReadTimeout int    `toml:"read_timeout"`
		WriteTimeout int   `toml:"write_timeout"`
	} `toml:"server"`

	StormDNS struct {
		Enabled bool   `toml:"enabled"`
		Domain  string `toml:"domain"`
		Backend string `toml:"backend"`
		Timeout int    `toml:"timeout"`
	} `toml:"stormdns"`

	MasterDNS struct {
		Enabled bool   `toml:"enabled"`
		Domain  string `toml:"domain"`
		Backend string `toml:"backend"`
		Timeout int    `toml:"timeout"`
	} `toml:"masterdns"`
}

func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var cfg Config

	if err := toml.Unmarshal(data, &cfg); err != nil {
		return nil, err
	}

	return &cfg, nil
}