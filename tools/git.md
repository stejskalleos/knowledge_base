# Git

## Cleanup
Cleanup review branches

```
git branch --list 'review*'  | xargs -r git branch -d -f
```

## Bisect
```
git bisect start
```

Select good and bad commits
```
git bisect good commit-sha
git bisect bad commit-sha
```

Iterate over commits and mark them.
```
# Commit still have the error
git bisect bad

# When the error is not there
git bisect good
```

End process
```
git bisect reset
```
