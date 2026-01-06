import pyexasol
import pytest

@pytest.fixture(scope="session")
def exasol_conn():
    conn = pyexasol.connect(
        dsn="localhost:8563",
        user="sys",
        password="exasol"
    )
    yield conn
    conn.close()

def test_github_integration(exasol_conn):
    exasol_conn.execute("CREATE SCHEMA IF NOT EXISTS TEST_SCHEMA")
    exasol_conn.execute("OPEN SCHEMA TEST_SCHEMA")

    exasol_conn.execute("""
        CREATE OR REPLACE TABLE REPOSITORIES(
            organization VARCHAR(100),
            repository   VARCHAR(200)
        )
    """)

    exasol_conn.execute("""
        INSERT INTO REPOSITORIES VALUES
        ('exasol','exasol-virtual-schema'),
        ('exasol','docker-db')
    """)

    with open("sql/create_udfs.sql") as f:
        exasol_conn.execute(f.read())

    rows = exasol_conn.execute("""
        SELECT
            organization,
            repository,
            github_latest_release_date(organization, repository),
            github_latest_release_version(organization, repository)
        FROM REPOSITORIES
    """).fetchall()

    assert len(rows) == 2

    for org, repo, date, version in rows:
        assert org is not None
        assert repo is not None
        if repo == "exasol-virtual-schema":
            assert version is not None
            assert len(version) > 0
        if repo == "docker-db":
            assert version is None
            assert date is None
