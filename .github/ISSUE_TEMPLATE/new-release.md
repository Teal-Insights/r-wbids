---
name: New release
about: Create a checklist for new version releases to CRAN and GitHub
title: Release Version <X.X.X>
labels: ''
assignees: ''

---

Prepare for release:

- [ ] Create a release issue from this template
- [ ] `git pull`
- [ ] `gh issue develop <issue_number> --checkout`
- [ ] `usethis::use_version('patch')`
- [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_packagename.html)
- [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
- [ ] `usethis::use_github_links()` (only for initial releases)
- [ ] `urlchecker::url_check()` (you will need pandoc installed on your OS to perform this step)
- [ ] `devtools::build_readme()`
- [ ] `devtools::check(remote = TRUE, manual = TRUE)`
- [ ] `devtools::check_win_devel()`
- [ ] `usethis::use_revdep()` (only for initial commits)
- [ ] `revdepcheck::revdep_check(num_workers = 4)`
- [ ] Update `cran-comments.md`
- [ ] `git push`

Submit to CRAN:

- [ ] `devtools::submit_cran()`
- [ ] Approve email

Wait for CRAN...

- [ ] Accepted 🎉
- [ ] `gh pr create`
- [ ] `gh pr merge` (select option to delete issue branch)
- [ ] `usethis::use_github_release()`
