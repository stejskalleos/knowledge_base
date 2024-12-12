# Git

Cleanup review branches

```
git branch --list 'review*'  | xargs -r git branch -d -f
```
