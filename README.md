# Mopidy Docker Server

A Docker image for running [Mopidy](https://mopidy.com/), a music server with support for multiple music sources and playback clients.

## Features

- **Mopidy Core** — Extensible music server
- **MPD Support** — Compatible with MPD clients via mopidy-mpd
- **Local Library** — Play music from your local collection
- **Iris Web UI** — Beautiful web interface for music management and playback
- **YouTube Integration** — Stream music from YouTube
- **Multi-platform** — Builds for both amd64 and arm64 (Raspberry Pi compatible)

## Installed Extensions

| Extension  | Purpose |
|-----------|---------|
| **Mopidy-MPD**  | MPD protocol support for compatible clients |
| **Mopidy-Local**  | Local music library support |
| **Mopidy-Iris** | Web-based UI and music browser |
| **Mopidy-YouTube**  | YouTube music streaming backend |
| **yt-dlp** | YouTube content downloader |

## Docker Compose Usage

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  mopidy:
    image: ghcr.io/ParagonIaC/mopidy-docker:latest
    container_name: mopidy
    ports:
      - "6600:6600"  # MPD protocol
      - "6680:6680"  # Iris web UI
      - "5555:5555/udp"  # Zeroconf/mDNS
    volumes:
      - ./config:/config
      - ./music:/music:ro  # Optional: local music library
    environment:
      - TZ=Europe/Berlin
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6680/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Getting Started

1. **Create config directory:**
   ```bash
   mkdir -p config music
   ```

2. **Create config file** — Create `config/mopidy.conf`:
   ```ini
   [core]
   cache_dir = /config/cache
   data_dir = /config/data

   [local]
   media_dir = /music

   [iris]
   enabled = true

   [youtube]
   enabled = true
   ```

3. **Start the service:**
   ```bash
   docker-compose up -d
   ```

4. **Access the web UI:**
   - Open http://localhost:6680 in your browser

## MPD Client Usage

Connect any MPD client to:
- **Host:** Your server IP or hostname
- **Port:** 6600

Popular MPD clients: ncmpcpp, Cantata, Mopidy, Volumio, Moode, etc.

## Configuration

Edit `config/mopidy.conf` to customize:
- Music library path
- YouTube preferences
- Audio output settings
- Iris UI settings

See [Mopidy documentation](https://docs.mopidy.com/) for all available options.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to open issues or pull requests.

## Support

For issues related to:
- **This Docker image** — Open an issue on GitHub
- **Mopidy itself** — See [Mopidy docs](https://docs.mopidy.com/)
- **Specific extensions** — Check their respective repositories
