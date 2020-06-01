---
title: "A robust Qt Cookiecutter Template: desktop and mobile, continuous integration, auto linters & formatters"
date: 2020-05-30T22:46:44-07:00
tags: ["Qt", "cookiecutter", "template", "android"]
---

My wife's company decided to share their [incredible Qt project template][219design-qt-template], Open Source (BSD)! If you're interested in building a user-facing application in C++, take a look. It gives you a lot out of the box.

[incredible Qt project template][219design-qt-template], Open Source (BSD)! If you're interested in building a user-facing application in C++, take a look. It gives you a lot out of the box.

* Continuous integration for your app via Github Actions' Workflows, triggered on every commit.
* Designed to be truly cross-platform: Windows, Mac, Linux, Android and iPhone!
* Preconfigured dev tools: formatters, linters, test runners.

I decided to make a cookiecutter template out of it to save you and I the hassle of hunting and replacing for namespaces, copyrights, etc.

## Quickstart

```bash
pip install cookiecutter
cookiecutter https://github.com/219-design/qt-qml-project-template-with-ci \
  --checkout origin/cookiecutter
```

[219design-qt-template]: https://github.com/219-design/qt-qml-project-template-with-ci
