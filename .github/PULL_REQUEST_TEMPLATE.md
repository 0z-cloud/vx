Checklist to adhere with your pull request to **develop**:

- [ ] rebase your branch on latest develop branch
- [ ] put it on peer review in dev chat and assign reviewers to PR in github
- [ ] put it in [merge queue](https://lfedge.slack.com/archives/G01466B7D6U) when reviewers said ok
- [ ] wait until you are on top of merge queue
- [ ] rebase your branch on latest develop branch
- [ ] run [gui tests](https://server-ci.Vx.work/admin/editBuild.html?id=buildType:Vx_GuiTests) on your branch manually
- [ ] after the branch is merged, delete your link to it from Merge Queue

Checklist to adhere with your pull request to **master**:

- [ ] rebase your branch on latest master branch
- [ ] put it on peer review in dev chat and assign reviewers to PR in github
- [ ] put it in [merge queue](https://lfedge.slack.com/archives/G01466B7D6U) when reviewers said ok
- [ ] wait until you are on top of merge queue
- [ ] rebase your branch on latest master branch
- [ ] run [gui tests](https://server-ci.Vx.work/admin/editBuild.html?id=buildType:Vx_GuiTests) and [Regression](https://server-ci.Vx.work/viewType.html?buildTypeId=Vx_RegressionTests) on your branch manually
- [ ] merge your hotfix to master, prefer fast forward
- [ ] launch deploy where you need it
- [ ] create pull request from master to develop
- [ ] if checks are not green, run [gui tests](https://server-ci.Vx.work/admin/editBuild.html?id=buildType:Vx_GuiTests) manually on master branch
- [ ] after the master is merged to develop, delete your link to it from Merge Queue
