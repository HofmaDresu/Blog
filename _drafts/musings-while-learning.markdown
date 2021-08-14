---
layout: post
title: "Musings while learning"
date: 2021-08-13 12:00:00 -0400
tags: not-the-damn-manager the-damn-manager
---

This post is just a bunch of things I encountered while catching up on tech for `[Not] The Damn Manager`. There won't be much of a through-line or story, as I just jot things down as I encounter them. This post may update a couple of times if I come across other things that fit in here better than their own post.

{% include notTheDamnManagerHomeLink.markdown %}

# Dependabot
So after publishing my 'coming back' post a few days ago GitHub created a few automated PRs for me (<a href="https://github.com/HofmaDresu/Blog/pull/1" rel="noopener" target="_blank">example</a>). This was a bit of a surprise so I read through the <a href="https://docs.github.com/en/code-security/supply-chain-security/managing-vulnerabilities-in-your-projects-dependencies/about-dependabot-security-updates" rel="noopener" target="_blank">documentation</a> included. What I can tell from a really quick read is it's an automated service that watches repositiories and security updates, and creates PRs if it sees a trivial patch to fix vulnerabilities. I of course merged the recommendations, and noticed another nice feature when it auto-rebased a later PR for me. This is a pretty awesome service, thanks GitHub!

# Using Preview Visual Studio
When updating all my tooling I noticed the 2022 preview for Visual Studio was available, so rather than updating to VS2019 I figured why not go to the preview? For the most part this has worked well so far, but I did hit one issue: While going through on of the Azure courses I needed to clone and run a specific repository, but when I tried to do so the project failed to run. Turns out it required a version of .NET Core 3 that wasn't installed with the preview. I'm guessing 2019 would have installed it, but just manually downloading + installing latest .NET Core version got me up and running so I'm sticking with 2022

# Azure Sandbox
Encountered this while going through some Azure lessons. It's a neat system that provisions Azure functionality to you for use while learning for free, so you don't need to spend money on hosting just to learn about it! Seems it lasts for 4 hours, and I can activate up to 10 today (every day?). Don't really know much more, just wanted to call out that this was a nice touch in the learning process.

# Azure Static Webapp
This is a pretty neat integration between Azure and GitHub that lets you automatically build and deploy updates using GitHub Actions. Azure sets everything up for you nicely so you just give it a little info and permissions and you get all the actions for free. It even builds 'staging' versions from PRs so you can view live before merging to main.

# C\#
I'm so far behind on C#, it's amazing what can happen in a couple years! I last coded seriously on 7.x and now there's a preview out for 10! It was fun to quickly read through the <a href="https://docs.microsoft.com/en-us/dotnet/csharp/whats-new/" target="_blank" rel="noopener">What's New Articles</a> for 8-10, though I think `[Not] The Damn Manager` is going to be too straightforward to take advantage of most of the new features. I also read through the 7.x article just to make sure I didn't miss anything in the point releases.

