# Orion Edge App

> **Quick Links:** See [`orchestrator_kit/README.md`](./orchestrator_kit/README.md) for orchestrator documentation and [`00_README.md`](./00_README.md) for the full launch kit overview.

This repository contains the orchestrator kit, deployment configurations, and automation tools for the edge application stack.

## Quick Start

```bash
docker compose -f deploy/cosmocrat-v1.compose.yml up -d
python3 jobs/memory/consolidate.py --commit
```

See [`docs/QUICKSTART.md`](./docs/QUICKSTART.md) for detailed setup instructions.

## Key Directories

- `orchestrator_kit/` - Canonical orchestrator documentation, artifacts, and prompts
- `deploy/` - Docker Compose configurations
- `docs/` - Setup guides and documentation
- `scripts/` - Utility scripts and automation tools
- `n8n/flows/` - n8n workflow definitions

## Documentation

- **Orchestrator Kit:** [`orchestrator_kit/README.md`](./orchestrator_kit/README.md)
- **Quick Start:** [`docs/QUICKSTART.md`](./docs/QUICKSTART.md)
- **Environment Templates:** [`docs/ENV_TEMPLATES.md`](./docs/ENV_TEMPLATES.md)
- **Launch Kit:** [`00_README.md`](./00_README.md)

