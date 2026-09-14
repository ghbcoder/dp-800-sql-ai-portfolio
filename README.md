# DP-800 SQL AI Portfolio

This repository documents my hands-on preparation for Microsoft DP-800: SQL AI Developer Associate.

## Projects

- 01-db-design — database design and development
- 02-secure-devops-api — security, optimization, deployment, and API integration
- 03-ai-rag — embeddings, vector search, hybrid search, and RAG
- docs — architecture notes, diagrams, and study documentation

## Azure Lab

- Resource group: rg-dp800-lab
- Azure SQL logical server: sql-dp800-881970
- Database: sqldb-dp800
- Region: Germany West Central

## Security approach

- Microsoft Entra authentication
- No SQL passwords committed to source control
- Local secrets excluded through .gitignore
- Managed identity / keyless authentication used where supported
