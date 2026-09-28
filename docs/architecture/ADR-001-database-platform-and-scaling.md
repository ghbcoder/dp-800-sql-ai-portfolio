# ADR-001: Database Platform and Scaling Strategy

- **Status:** Accepted
- **Date:** 2026-09-28
- **Project:** AI-Enabled Support Knowledge Platform

## Context

The AI-Enabled Support Knowledge Platform requires a relational database platform that supports:

- T-SQL and relational transactions
- Referential integrity and database constraints
- Stored procedures and reusable query logic
- JSON metadata for evolving AI-related attributes
- System-versioned temporal tables for historical data
- Future AI-enabled database capabilities
- Managed infrastructure with no requirement to administer database virtual machines

The initial workload is expected to be intermittent and unpredictable, with periods of little or no database activity. Cost efficiency is therefore important during the early stages of the platform.

The architecture must also provide a path for future growth without assuming that the initial workload characteristics will remain unchanged.

## Decision

Use **Azure SQL Database** as the primary relational database platform.

For the initial workload, use the **General Purpose serverless compute tier**.

This decision is based on the following requirements:

- Azure SQL Database provides a managed PaaS database platform, avoiding the operational overhead of managing SQL Server virtual machines.
- The platform supports the relational and T-SQL capabilities required by the application.
- System-versioned temporal tables support point-in-time reconstruction and historical row versions.
- JSON support allows evolving AI-related metadata to coexist with strongly relational application data.
- Serverless compute aligns with the initial intermittent and unpredictable workload and provides auto-pause capability when the database is eligible.
- General Purpose provides an appropriate starting service tier for the initial workload without prematurely selecting a higher-cost architecture.

The architecture will be re-evaluated as workload characteristics, performance requirements, data volume, and business requirements evolve.

## Alternatives Considered

### Azure SQL Database with Provisioned Compute

Provisioned compute was considered but not selected for the initial workload.

The initial demand is expected to be intermittent and unpredictable, so continuously provisioned compute does not currently align as closely with the workload profile as serverless compute.

Provisioned compute remains a future option if the workload develops a stable, sustained baseline or strict latency requirements make serverless resume behavior undesirable.

### SQL Server on Azure Virtual Machines

SQL Server on Azure Virtual Machines was considered because it provides greater control over the SQL Server instance and underlying operating system.

It was not selected because the current application does not require instance-level or operating-system-level control, and the project favors managed database infrastructure with lower administrative overhead.

This option should be reconsidered if future requirements depend on SQL Server capabilities that are unavailable or unsuitable in Azure SQL Database.

### Horizontal Distribution / Sharding

Sharding was not selected for the initial architecture because the current workload does not justify the additional complexity of distributing data and transactions across multiple databases.

Horizontal distribution should only be evaluated when optimization, vertical scaling, workload separation, and appropriate data-layout strategies are no longer sufficient for the required scale.

## Consequences and Tradeoffs

### Positive Consequences

- The database platform is managed as a PaaS service, reducing infrastructure administration.
- The application can continue using T-SQL, relational constraints, transactions, stored procedures, JSON, and temporal capabilities.
- Serverless compute can adapt to intermittent demand.
- Auto-pause can reduce unnecessary compute usage during eligible idle periods.
- The initial architecture remains relatively simple while preserving multiple future scaling options.

### Tradeoffs

- A serverless database that has auto-paused must resume when a new connection arrives. The first request may therefore experience additional latency.
- Application connection and retry behavior must account for database resume scenarios.
- If the workload becomes continuously active, the auto-pause benefit may disappear.
- Azure SQL Database does not provide the same level of instance and operating-system control as SQL Server on an Azure Virtual Machine.
- Read scaling may introduce data-freshness considerations for workloads routed to replicas.
- Partitioning can improve manageability and enable partition elimination for aligned predicates, but it does not create independent compute nodes or replace horizontal scaling.
- Horizontal distribution introduces significant application and operational complexity and should not be introduced prematurely.

## Scaling and Re-evaluation Triggers

The architecture should be re-evaluated when measured workload characteristics indicate that the assumptions behind the current design have changed.

### Serverless to Provisioned Compute

Evaluate provisioned compute when:

- database activity becomes sustained or approaches 24/7 operation;
- the workload develops a stable and predictable compute baseline;
- auto-pause is rarely or never used;
- resume latency conflicts with application latency or SLA requirements.

### Vertical Scaling

Evaluate additional compute resources when:

- sustained CPU, memory, or I/O pressure is observed;
- query and index optimization have already been investigated;
- the workload can still reasonably be served by a single database.

### Read Scaling

Evaluate read replicas or other read-scaling capabilities when:

- read-heavy workloads place significant pressure on the primary database;
- reporting or analytical queries can tolerate replication latency;
- consistency-sensitive and read-after-write operations can remain on the primary.

### Partitioning

Evaluate or expand table partitioning when:

- tables grow to very large row counts;
- major query patterns align with a suitable partitioning key such as `CreatedAt`;
- partition elimination can reduce unnecessary data access;
- time-based data lifecycle or historical-data management becomes operationally important.

Partitioning must not be treated as equivalent to horizontal scaling. It organizes data within the database and does not inherently provide independent compute resources.

### Horizontal Distribution

Evaluate horizontal distribution or sharding when:

- query and index optimization have been performed;
- appropriate vertical scaling has been evaluated;
- eligible read workloads have been separated where appropriate;
- partitioning and data-lifecycle strategies are being used effectively;
- the workload or data volume is still approaching a fundamental single-database limitation.

## Compatibility Considerations

Azure SQL Database and SQL Server share the T-SQL ecosystem, but this does not guarantee that every SQL Server workload can migrate unchanged to Azure SQL Database.

Before migrating an existing SQL Server workload, perform a feature and dependency assessment, paying particular attention to:

- instance-level dependencies;
- operating-system-level integrations;
- unsupported or differently implemented SQL Server features;
- operational and administrative requirements;
- application assumptions about the underlying SQL Server environment.

Database compatibility level can help control database and query-processing behavior during platform evolution, but it does not guarantee platform-level feature compatibility.

## Architecture Review Principle

Architecture decisions are based on requirements, constraints, and workload characteristics at a point in time.

A change in architecture does not necessarily mean the original decision was incorrect. When the assumptions that justified a decision materially change, the architecture should be re-evaluated using current workload measurements and business requirements.

## Current Decision Summary

| Area | Current Decision |
|---|---|
| Database platform | Azure SQL Database |
| Service tier | General Purpose |
| Compute model | Serverless |
| Region | Germany West Central |
| Historical data | System-versioned temporal tables |
| Flexible AI metadata | Validated JSON alongside relational data |
| Initial scaling approach | Optimize, then scale vertically when justified |
| Read-heavy growth | Evaluate read scaling for eligible workloads |
| Very large time-oriented tables | Evaluate `CreatedAt`-aligned partitioning |
| Single-database scaling limit | Evaluate horizontal distribution only when justified |