SELECT
  organization,
  repository,
  github_latest_release_date(organization, repository)    AS latest_rel_date,
  github_latest_release_version(organization, repository) AS latest_rel_version
FROM REPOSITORIES;
