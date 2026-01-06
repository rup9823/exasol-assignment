# Exasol GitHub UDF Integration

This project implements a Python-based integration between Exasol and the GitHub REST API.
It provides scalar UDFs that enrich repository data with the latest GitHub release version
and release date.

## Overview

Given a table with GitHub repositories:

- organization
- repository

the integration allows querying live GitHub release metadata directly from SQL.

The integration is implemented using scalar Python UDFs, which are the idiomatic way to
perform row-wise enrichment in Exasol.

## Design Decisions

- All logic is contained inside the `run(ctx)` function to ensure compatibility with
  the Exasol Python UDF runtime.
- A timeout is applied to all HTTP calls to avoid blocking SQL execution.
- Lightweight in-process caching is used to reduce unnecessary GitHub API calls.
- HTTP 404 responses (repositories without releases) return NULL values.

## Usage Example

```sql
SELECT
  organization,
  repository,
  github_latest_release_date(organization, repository)    AS latest_rel_date,
  github_latest_release_version(organization, repository) AS latest_rel_version
FROM REPOSITORIES;
