# AI-Enabled Support Knowledge Platform

A hands-on Azure SQL engineering project for an AI-enabled customer-support platform.

The solution manages the lifecycle of customer-support tickets, preserves historical changes, and builds reusable support knowledge that can later support AI-powered retrieval and assistance.

This repository also serves as my practical portfolio while preparing for Microsoft DP-800: SQL AI Developer Associate.

## Business Scenario

The platform is designed to support a customer-service workflow where:

1. Customers create support tickets.
2. Agents investigate and exchange messages with customers.
3. Ticket status progresses through the support lifecycle.
4. Historical ticket states remain available for investigation and auditing.
5. Resolved issues can contribute to a curated knowledge base.
6. The knowledge base can later become a source for AI-powered retrieval and assistance.

## Current Architecture

```text
Customer / Support Application
            |
            v
      Azure SQL Database
            |
    +-------+-------------------+
    |       |                   |
    v       v                   v
Customers  SupportTickets   KnowledgeArticles
              |
              v
        TicketMessages
```

The current database platform is Azure SQL Database using a General Purpose serverless configuration.

The architecture is designed to evolve as workload characteristics change. Scaling decisions and re-evaluation triggers are documented in `docs/architecture/ADR-001-database-platform-and-scaling.md`.

## Database Engineering

The SQL Database Project currently implements:

- relational modeling with primary and foreign keys
- data-integrity constraints and defaults
- reusable stored procedures, functions, and views
- transaction-safe ticket creation
- JSON metadata for evolving AI-related attributes
- system-versioned temporal history for support tickets
- reusable sequence objects
- partitioning infrastructure for time-oriented ticket data
- workload-oriented indexes
- SQL Database Project build and deployment workflow

## Query and Performance Engineering

The repository also contains hands-on SQL investigations covering:

- set-based query design
- CTEs
- `CROSS APPLY` and `OUTER APPLY`
- window functions
- transaction isolation and blocking
- deadlock behavior
- snapshot-based concurrency
- execution plans and logical I/O
- plan caching and parameter sensitivity
- Query Store analysis
- temporal querying

These exercises are retained under `01-db-design/queries/domain-01/` as reproducible engineering labs.

## Architecture Decisions

Architecture decisions are documented as ADRs under `docs/architecture/`.

Current ADR:

- `ADR-001-database-platform-and-scaling.md` - Azure SQL platform selection, serverless versus provisioned compute, compatibility considerations, vertical scaling, read scaling, partitioning, and triggers for evaluating horizontal distribution.

## Repository Structure

```text
.
|-- 01-db-design/
|   |-- SupportKnowledgePlatform/
|   |   |-- Functions/
|   |   |-- Partitioning/
|   |   |-- Sequences/
|   |   |-- Stored Procedures/
|   |   |-- Tables/
|   |   |-- Views/
|   |   `-- SupportKnowledgePlatform.sqlproj
|   `-- queries/
|       `-- domain-01/
|
|-- 02-secure-devops-api/
|-- 03-ai-rag/
|-- docs/
|   `-- architecture/
|       `-- ADR-001-database-platform-and-scaling.md
|-- .env.example
|-- .gitignore
`-- README.md
```

## Security Approach

The project is designed around keyless authentication and source-control hygiene:

- Microsoft Entra authentication
- no SQL passwords committed to source control
- local secrets excluded through `.gitignore`
- managed identity / keyless authentication where supported
- generated build artifacts excluded from Git

## Project Roadmap

### Database Design and Development

Relational design, programmability, advanced T-SQL, indexing, concurrency, temporal data, performance analysis, and architecture decisions.

**Status:** in progress.

### Secure DevOps and API Integration

Security, identity, deployment automation, CI/CD, database testing, operational optimization, and application/API integration.

**Status:** planned.

### AI and RAG

Embeddings, vector search, hybrid retrieval, knowledge retrieval, and retrieval-augmented generation using the support knowledge platform.

**Status:** planned.

## Certification Context

This project supports hands-on preparation for Microsoft DP-800: SQL AI Developer Associate while also serving as a practical demonstration of Azure SQL database engineering and AI-ready application architecture.
