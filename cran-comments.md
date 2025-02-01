## R CMD check results

0 errors | 0 warnings | 0 notes

### CRAN comments

>It seems we need to remind you of the CRAN policy:
>
>'Packages which use Internet resources should fail gracefully with an informative message
>if the resource is not available or has changed (and not give a check warning nor error).'

Fixed; the test in question now uses a mock for the invalid URL rather than actually trying to access it.
