


<!DOCTYPE html>
<html lang="en" class=" is-copy-enabled">
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# object: http://ogp.me/ns/object# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Language" content="en">
    <meta name="viewport" content="width=1020">
    
    
    <title>IDA_loader/nintendo_gb.py at master · w4kfu/IDA_loader · GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub">
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub">
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png">
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png">
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png">
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png">
    <meta property="fb:app_id" content="1401488693436528">

      <meta content="@github" name="twitter:site" /><meta content="summary" name="twitter:card" /><meta content="w4kfu/IDA_loader" name="twitter:title" /><meta content="IDA_loader - Some loader module for IDA" name="twitter:description" /><meta content="https://avatars0.githubusercontent.com/u/618271?v=3&amp;s=400" name="twitter:image:src" />
      <meta content="GitHub" property="og:site_name" /><meta content="object" property="og:type" /><meta content="https://avatars0.githubusercontent.com/u/618271?v=3&amp;s=400" property="og:image" /><meta content="w4kfu/IDA_loader" property="og:title" /><meta content="https://github.com/w4kfu/IDA_loader" property="og:url" /><meta content="IDA_loader - Some loader module for IDA" property="og:description" />
      <meta name="browser-stats-url" content="https://api.github.com/_private/browser/stats">
    <meta name="browser-errors-url" content="https://api.github.com/_private/browser/errors">
    <link rel="assets" href="https://assets-cdn.github.com/">
    
    <meta name="pjax-timeout" content="1000">
    

    <meta name="msapplication-TileImage" content="/windows-tile.png">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="selected-link" value="repo_source" data-pjax-transient>

    <meta name="google-site-verification" content="KT5gs8h0wvaagLKAVWq8bbeNwnZZK1r1XQysX3xurLU">
    <meta name="google-analytics" content="UA-3769691-2">

<meta content="collector.githubapp.com" name="octolytics-host" /><meta content="github" name="octolytics-app-id" /><meta content="CBD915E8:3F5A:A4DABE1:5656A27C" name="octolytics-dimension-request_id" />
<meta content="/&lt;user-name&gt;/&lt;repo-name&gt;/blob/show" data-pjax-transient="true" name="analytics-location" />
<meta content="Rails, view, blob#show" data-pjax-transient="true" name="analytics-event" />


  <meta class="js-ga-set" name="dimension1" content="Logged Out">
    <meta class="js-ga-set" name="dimension4" content="Current repo nav">




    <meta name="is-dotcom" content="true">
        <meta name="hostname" content="github.com">
    <meta name="user-login" content="">

      <link rel="mask-icon" href="https://assets-cdn.github.com/pinned-octocat.svg" color="#4078c0">
      <link rel="icon" type="image/x-icon" href="https://assets-cdn.github.com/favicon.ico">

    <meta content="7ff04a81ca6db5a9259540b0ccbaf6d7f6263823" name="form-nonce" />

    <link crossorigin="anonymous" href="https://assets-cdn.github.com/assets/github-3698fb0adc53fda9a2672a02c3fa3b20b89480f2a47ce38216b21cf3eb5b4750.css" media="all" rel="stylesheet" />
    <link crossorigin="anonymous" href="https://assets-cdn.github.com/assets/github2-912fc0b3ba75b656d2d1687e8be122647344ab57d955de8f6635ee88161cf450.css" media="all" rel="stylesheet" />
    
    
    


    <meta http-equiv="x-pjax-version" content="dd39fae7621416ea1170f4f42e76f703">

      
  <meta name="description" content="IDA_loader - Some loader module for IDA">
  <meta name="go-import" content="github.com/w4kfu/IDA_loader git https://github.com/w4kfu/IDA_loader.git">

  <meta content="618271" name="octolytics-dimension-user_id" /><meta content="w4kfu" name="octolytics-dimension-user_login" /><meta content="7054047" name="octolytics-dimension-repository_id" /><meta content="w4kfu/IDA_loader" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="7054047" name="octolytics-dimension-repository_network_root_id" /><meta content="w4kfu/IDA_loader" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/w4kfu/IDA_loader/commits/master.atom" rel="alternate" title="Recent Commits to IDA_loader:master" type="application/atom+xml">

  </head>


  <body class="logged_out   env-production windows vis-public page-blob">
    <a href="#start-of-content" tabindex="1" class="accessibility-aid js-skip-to-content">Skip to content</a>

    
    
    



      
      <div class="header header-logged-out" role="banner">
  <div class="container clearfix">

    <a class="header-logo-wordmark" href="https://github.com/" data-ga-click="(Logged out) Header, go to homepage, icon:logo-wordmark">
      <span class="mega-octicon octicon-logo-github"></span>
    </a>

    <div class="header-actions" role="navigation">
        <a class="btn btn-primary" href="/join" data-ga-click="(Logged out) Header, clicked Sign up, text:sign-up">Sign up</a>
      <a class="btn" href="/login?return_to=%2Fw4kfu%2FIDA_loader%2Fblob%2Fmaster%2FNintendo_GB%2Fnintendo_gb.py" data-ga-click="(Logged out) Header, clicked Sign in, text:sign-in">Sign in</a>
    </div>

    <div class="site-search repo-scope js-site-search" role="search">
      <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/w4kfu/IDA_loader/search" class="js-site-search-form" data-global-search-url="/search" data-repo-search-url="/w4kfu/IDA_loader/search" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
  <label class="js-chromeless-input-container form-control">
    <div class="scope-badge">This repository</div>
    <input type="text"
      class="js-site-search-focus js-site-search-field is-clearable chromeless-input"
      data-hotkey="s"
      name="q"
      placeholder="Search"
      aria-label="Search this repository"
      data-global-scope-placeholder="Search GitHub"
      data-repo-scope-placeholder="Search"
      tabindex="1"
      autocapitalize="off">
  </label>
</form>
    </div>

      <ul class="header-nav left" role="navigation">
          <li class="header-nav-item">
            <a class="header-nav-link" href="/explore" data-ga-click="(Logged out) Header, go to explore, text:explore">Explore</a>
          </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="/features" data-ga-click="(Logged out) Header, go to features, text:features">Features</a>
          </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="https://enterprise.github.com/" data-ga-click="(Logged out) Header, go to enterprise, text:enterprise">Enterprise</a>
          </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="/pricing" data-ga-click="(Logged out) Header, go to pricing, text:pricing">Pricing</a>
          </li>
      </ul>

  </div>
</div>



    <div id="start-of-content" class="accessibility-aid"></div>

    <div id="js-flash-container">
</div>


    <div role="main" class="main-content">
        <div itemscope itemtype="http://schema.org/WebPage">
    <div class="pagehead repohead instapaper_ignore readability-menu">

      <div class="container">

        <div class="clearfix">
          

<ul class="pagehead-actions">

  <li>
      <a href="/login?return_to=%2Fw4kfu%2FIDA_loader"
    class="btn btn-sm btn-with-count tooltipped tooltipped-n"
    aria-label="You must be signed in to watch a repository" rel="nofollow">
    <span class="octicon octicon-eye"></span>
    Watch
  </a>
  <a class="social-count" href="/w4kfu/IDA_loader/watchers">
    3
  </a>

  </li>

  <li>
      <a href="/login?return_to=%2Fw4kfu%2FIDA_loader"
    class="btn btn-sm btn-with-count tooltipped tooltipped-n"
    aria-label="You must be signed in to star a repository" rel="nofollow">
    <span class="octicon octicon-star"></span>
    Star
  </a>

    <a class="social-count js-social-count" href="/w4kfu/IDA_loader/stargazers">
      4
    </a>

  </li>

  <li>
      <a href="/login?return_to=%2Fw4kfu%2FIDA_loader"
        class="btn btn-sm btn-with-count tooltipped tooltipped-n"
        aria-label="You must be signed in to fork a repository" rel="nofollow">
        <span class="octicon octicon-repo-forked"></span>
        Fork
      </a>

    <a href="/w4kfu/IDA_loader/network" class="social-count">
      5
    </a>
  </li>
</ul>

          <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public ">
  <span class="mega-octicon octicon-repo"></span>
  <span class="author"><a href="/w4kfu" class="url fn" itemprop="url" rel="author"><span itemprop="title">w4kfu</span></a></span><!--
--><span class="path-divider">/</span><!--
--><strong><a href="/w4kfu/IDA_loader" data-pjax="#js-repo-pjax-container">IDA_loader</a></strong>

  <span class="page-context-loader">
    <img alt="" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
  </span>

</h1>

        </div>
      </div>
    </div>

    <div class="container">
      <div class="repository-with-sidebar repo-container new-discussion-timeline ">
        <div class="repository-sidebar clearfix">
          
<nav class="sunken-menu repo-nav js-repo-nav js-sidenav-container-pjax js-octicon-loaders"
     role="navigation"
     data-pjax="#js-repo-pjax-container"
     data-issue-count-url="/w4kfu/IDA_loader/issues/counts">
  <ul class="sunken-menu-group">
    <li class="tooltipped tooltipped-w" aria-label="Code">
      <a href="/w4kfu/IDA_loader" aria-label="Code" aria-selected="true" class="js-selected-navigation-item selected sunken-menu-item" data-hotkey="g c" data-selected-links="repo_source repo_downloads repo_commits repo_releases repo_tags repo_branches /w4kfu/IDA_loader">
        <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
        <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>

      <li class="tooltipped tooltipped-w" aria-label="Issues">
        <a href="/w4kfu/IDA_loader/issues" aria-label="Issues" class="js-selected-navigation-item sunken-menu-item" data-hotkey="g i" data-selected-links="repo_issues repo_labels repo_milestones /w4kfu/IDA_loader/issues">
          <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
          <span class="js-issue-replace-counter"></span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

    <li class="tooltipped tooltipped-w" aria-label="Pull requests">
      <a href="/w4kfu/IDA_loader/pulls" aria-label="Pull requests" class="js-selected-navigation-item sunken-menu-item" data-hotkey="g p" data-selected-links="repo_pulls /w4kfu/IDA_loader/pulls">
          <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull requests</span>
          <span class="js-pull-replace-counter"></span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>

  </ul>
  <div class="sunken-menu-separator"></div>
  <ul class="sunken-menu-group">

    <li class="tooltipped tooltipped-w" aria-label="Pulse">
      <a href="/w4kfu/IDA_loader/pulse" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-selected-links="pulse /w4kfu/IDA_loader/pulse">
        <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
        <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>

    <li class="tooltipped tooltipped-w" aria-label="Graphs">
      <a href="/w4kfu/IDA_loader/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-selected-links="repo_graphs repo_contributors /w4kfu/IDA_loader/graphs">
        <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
        <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>
  </ul>


</nav>

            <div class="only-with-full-nav">
                
<div class="js-clone-url clone-url open"
  data-protocol-type="http">
  <h3 class="text-small text-muted"><span class="text-emphasized">HTTPS</span> clone URL</h3>
  <div class="input-group js-zeroclipboard-container">
    <input type="text" class="input-mini text-small text-muted input-monospace js-url-field js-zeroclipboard-target"
           value="https://github.com/w4kfu/IDA_loader.git" readonly="readonly" aria-label="HTTPS clone URL">
    <span class="input-group-button">
      <button aria-label="Copy to clipboard" class="js-zeroclipboard btn btn-sm zeroclipboard-button tooltipped tooltipped-s" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>

  
<div class="js-clone-url clone-url "
  data-protocol-type="subversion">
  <h3 class="text-small text-muted"><span class="text-emphasized">Subversion</span> checkout URL</h3>
  <div class="input-group js-zeroclipboard-container">
    <input type="text" class="input-mini text-small text-muted input-monospace js-url-field js-zeroclipboard-target"
           value="https://github.com/w4kfu/IDA_loader" readonly="readonly" aria-label="Subversion checkout URL">
    <span class="input-group-button">
      <button aria-label="Copy to clipboard" class="js-zeroclipboard btn btn-sm zeroclipboard-button tooltipped tooltipped-s" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>



<div class="clone-options text-small text-muted">You can clone with
  <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone" class="inline-form js-clone-selector-form " data-form-nonce="7ff04a81ca6db5a9259540b0ccbaf6d7f6263823" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="3HCy4rb6lNLTqS7Tkgd8jh5EK9R5r0FUv41jzyPA7VKP0DDs2+CznI9DsEhvZomOzEMXkHJPAo+mf5Py0/UClA==" /></div><button class="btn-link js-clone-selector" data-protocol="http" type="submit">HTTPS</button></form> or <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone" class="inline-form js-clone-selector-form " data-form-nonce="7ff04a81ca6db5a9259540b0ccbaf6d7f6263823" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="aKWIHUQMWfaQ/YZvMjCL/C6+kD+bVZ1SlHrOfQ6KXJ0dPCvp0YtOLIN4IMPTNGV/UC4TGiITLf22dfdL65OX9A==" /></div><button class="btn-link js-clone-selector" data-protocol="subversion" type="submit">Subversion</button></form>.
  <a href="https://help.github.com/articles/which-remote-url-should-i-use" class="help tooltipped tooltipped-n" aria-label="Get help on which URL is right for you.">
    <span class="octicon octicon-question"></span>
  </a>
</div>
  <a href="https://windows.github.com" class="btn btn-sm sidebar-button" title="Save w4kfu/IDA_loader to your computer and use it in GitHub Desktop." aria-label="Save w4kfu/IDA_loader to your computer and use it in GitHub Desktop.">
    <span class="octicon octicon-desktop-download"></span>
    Clone in Desktop
  </a>

              <a href="/w4kfu/IDA_loader/archive/master.zip"
                 class="btn btn-sm sidebar-button"
                 aria-label="Download the contents of w4kfu/IDA_loader as a zip file"
                 title="Download the contents of w4kfu/IDA_loader as a zip file"
                 rel="nofollow">
                <span class="octicon octicon-cloud-download"></span>
                Download ZIP
              </a>
            </div>
        </div>
        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>

          

<a href="/w4kfu/IDA_loader/blob/18870931a1e59d42a05a29f1068d0dbe99243649/Nintendo_GB/nintendo_gb.py" class="hidden js-permalink-shortcut" data-hotkey="y">Permalink</a>

<!-- blob contrib key: blob_contributors:v21:3d95c6986fe98578a9de4bb052b30672 -->

  <div class="file-navigation js-zeroclipboard-container">
    
<div class="select-menu js-menu-container js-select-menu left">
  <button class="btn btn-sm select-menu-button js-menu-target css-truncate" data-hotkey="w"
    title="master"
    type="button" aria-label="Switch branches or tags" tabindex="0" aria-haspopup="true">
    <i>Branch:</i>
    <span class="js-select-button css-truncate-target">master</span>
  </button>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax aria-hidden="true">

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="octicon octicon-x js-menu-close" role="button" aria-label="Close"></span>
        <span class="select-menu-title">Switch branches/tags</span>
      </div>

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" data-filter-placeholder="Filter branches/tags" class="js-select-menu-tab" role="tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" data-filter-placeholder="Find a tag…" class="js-select-menu-tab" role="tab">Tags</a>
            </li>
          </ul>
        </div>
      </div>

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches" role="menu">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <a class="select-menu-item js-navigation-item js-navigation-open selected"
               href="/w4kfu/IDA_loader/blob/master/Nintendo_GB/nintendo_gb.py"
               data-name="master"
               data-skip-pjax="true"
               rel="nofollow">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <span class="select-menu-item-text css-truncate-target" title="master">
                master
              </span>
            </a>
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div>

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div>

    </div>
  </div>
</div>

    <div class="btn-group right">
      <a href="/w4kfu/IDA_loader/find/master"
            class="js-show-file-finder btn btn-sm empty-icon tooltipped tooltipped-nw"
            data-pjax
            data-hotkey="t"
            aria-label="Quickly jump between files">
        <span class="octicon octicon-list-unordered"></span>
      </a>
      <button aria-label="Copy file path to clipboard" class="js-zeroclipboard btn btn-sm zeroclipboard-button tooltipped tooltipped-s" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </div>

    <div class="breadcrumb js-zeroclipboard-target">
      <span class="repo-root js-repo-root"><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/w4kfu/IDA_loader" class="" data-branch="master" data-pjax="true" itemscope="url"><span itemprop="title">IDA_loader</span></a></span></span><span class="separator">/</span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/w4kfu/IDA_loader/tree/master/Nintendo_GB" class="" data-branch="master" data-pjax="true" itemscope="url"><span itemprop="title">Nintendo_GB</span></a></span><span class="separator">/</span><strong class="final-path">nintendo_gb.py</strong>
    </div>
  </div>


  <div class="commit-tease">
      <span class="right">
        <a class="commit-tease-sha" href="/w4kfu/IDA_loader/commit/61cc6f03d4c003bfd51372417b1890215d105e80" data-pjax>
          61cc6f0
        </a>
        <time datetime="2012-12-07T22:08:35Z" is="relative-time">Dec 7, 2012</time>
      </span>
      <div>
        <img alt="@w4kfu" class="avatar" height="20" src="https://avatars3.githubusercontent.com/u/618271?v=3&amp;s=40" width="20" />
        <a href="/w4kfu" class="user-mention" rel="author">w4kfu</a>
          <a href="/w4kfu/IDA_loader/commit/61cc6f03d4c003bfd51372417b1890215d105e80" class="message" data-pjax="true" title="Fix 16bit segments">Fix 16bit segments</a>
      </div>

    <div class="commit-tease-contributors">
      <a class="muted-link contributors-toggle" href="#blob_contributors_box" rel="facebox">
        <strong>1</strong>
         contributor
      </a>
      
    </div>

    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header" data-facebox-id="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list" data-facebox-id="facebox-description">
          <li class="facebox-user-list-item">
            <img alt="@w4kfu" height="24" src="https://avatars1.githubusercontent.com/u/618271?v=3&amp;s=48" width="24" />
            <a href="/w4kfu">w4kfu</a>
          </li>
      </ul>
    </div>
  </div>

<div class="file">
  <div class="file-header">
  <div class="file-actions">

    <div class="btn-group">
      <a href="/w4kfu/IDA_loader/raw/master/Nintendo_GB/nintendo_gb.py" class="btn btn-sm " id="raw-url">Raw</a>
        <a href="/w4kfu/IDA_loader/blame/master/Nintendo_GB/nintendo_gb.py" class="btn btn-sm js-update-url-with-hash">Blame</a>
      <a href="/w4kfu/IDA_loader/commits/master/Nintendo_GB/nintendo_gb.py" class="btn btn-sm " rel="nofollow">History</a>
    </div>

        <a class="octicon-btn tooltipped tooltipped-nw"
           href="https://windows.github.com"
           aria-label="Open this file in GitHub Desktop"
           data-ga-click="Repository, open with desktop, type:windows">
            <span class="octicon octicon-device-desktop"></span>
        </a>

        <button type="button" class="octicon-btn disabled tooltipped tooltipped-nw"
          aria-label="You must be signed in to make or propose changes">
          <span class="octicon octicon-pencil"></span>
        </button>
        <button type="button" class="octicon-btn octicon-btn-danger disabled tooltipped tooltipped-nw"
          aria-label="You must be signed in to make or propose changes">
          <span class="octicon octicon-trashcan"></span>
        </button>
  </div>

  <div class="file-info">
      246 lines (224 sloc)
      <span class="file-info-divider"></span>
    7.92 KB
  </div>
</div>

  

  <div class="blob-wrapper data type-python">
      <table class="highlight tab-size js-file-line-container" data-tab-size="8">
      <tr>
        <td id="L1" class="blob-num js-line-number" data-line-number="1"></td>
        <td id="LC1" class="blob-code blob-code-inner js-file-line"><span class="pl-k">import</span> idc </td>
      </tr>
      <tr>
        <td id="L2" class="blob-num js-line-number" data-line-number="2"></td>
        <td id="LC2" class="blob-code blob-code-inner js-file-line"><span class="pl-k">import</span> idaapi</td>
      </tr>
      <tr>
        <td id="L3" class="blob-num js-line-number" data-line-number="3"></td>
        <td id="LC3" class="blob-code blob-code-inner js-file-line"><span class="pl-k">import</span> struct</td>
      </tr>
      <tr>
        <td id="L4" class="blob-num js-line-number" data-line-number="4"></td>
        <td id="LC4" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L5" class="blob-num js-line-number" data-line-number="5"></td>
        <td id="LC5" class="blob-code blob-code-inner js-file-line">ROM_SIGNATURE_OFFSET 	<span class="pl-k">=</span> <span class="pl-c1">0x</span>104</td>
      </tr>
      <tr>
        <td id="L6" class="blob-num js-line-number" data-line-number="6"></td>
        <td id="LC6" class="blob-code blob-code-inner js-file-line">ROM_SIGNATURE        	<span class="pl-k">=</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-cce">\xCE\xED\x66\x66\xCC\x0D\x00\x0B\x03\x73\x00\x83\x00\x0C\x00\x0D</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L7" class="blob-num js-line-number" data-line-number="7"></td>
        <td id="LC7" class="blob-code blob-code-inner js-file-line">ROM_SIGNATURE		<span class="pl-k">+=</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-cce">\x00\x08\x11\x1F\x88\x89\x00\x0E\xDC\xCC\x6E\xE6\xDD\xDD\xD9\x99</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L8" class="blob-num js-line-number" data-line-number="8"></td>
        <td id="LC8" class="blob-code blob-code-inner js-file-line">ROM_SIGNATURE		<span class="pl-k">+=</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-cce">\xBB\xBB\x67\x63\x6E\x0E\xEC\xCC\xDD\xDC\x99\x9F\xBB\xB9\x33\x3E</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L9" class="blob-num js-line-number" data-line-number="9"></td>
        <td id="LC9" class="blob-code blob-code-inner js-file-line">ROM_SIGNATURE_LENGTH	<span class="pl-k">=</span> <span class="pl-c1">0x</span>30</td>
      </tr>
      <tr>
        <td id="L10" class="blob-num js-line-number" data-line-number="10"></td>
        <td id="LC10" class="blob-code blob-code-inner js-file-line">ROM_FORMAT_NAME        	<span class="pl-k">=</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Nintendo GB ROM<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L11" class="blob-num js-line-number" data-line-number="11"></td>
        <td id="LC11" class="blob-code blob-code-inner js-file-line">SIZE_HEADER		<span class="pl-k">=</span> <span class="pl-c1">0x</span>150</td>
      </tr>
      <tr>
        <td id="L12" class="blob-num js-line-number" data-line-number="12"></td>
        <td id="LC12" class="blob-code blob-code-inner js-file-line">ROM0_START		<span class="pl-k">=</span> <span class="pl-c1">0</span></td>
      </tr>
      <tr>
        <td id="L13" class="blob-num js-line-number" data-line-number="13"></td>
        <td id="LC13" class="blob-code blob-code-inner js-file-line">ROM0_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>4000</td>
      </tr>
      <tr>
        <td id="L14" class="blob-num js-line-number" data-line-number="14"></td>
        <td id="LC14" class="blob-code blob-code-inner js-file-line">ROM1_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>4000</td>
      </tr>
      <tr>
        <td id="L15" class="blob-num js-line-number" data-line-number="15"></td>
        <td id="LC15" class="blob-code blob-code-inner js-file-line">ROM1_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>4000</td>
      </tr>
      <tr>
        <td id="L16" class="blob-num js-line-number" data-line-number="16"></td>
        <td id="LC16" class="blob-code blob-code-inner js-file-line">VRAM_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>8000</td>
      </tr>
      <tr>
        <td id="L17" class="blob-num js-line-number" data-line-number="17"></td>
        <td id="LC17" class="blob-code blob-code-inner js-file-line">VRAM_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>2000</td>
      </tr>
      <tr>
        <td id="L18" class="blob-num js-line-number" data-line-number="18"></td>
        <td id="LC18" class="blob-code blob-code-inner js-file-line">RAM1_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>A000</td>
      </tr>
      <tr>
        <td id="L19" class="blob-num js-line-number" data-line-number="19"></td>
        <td id="LC19" class="blob-code blob-code-inner js-file-line">RAM1_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>2000</td>
      </tr>
      <tr>
        <td id="L20" class="blob-num js-line-number" data-line-number="20"></td>
        <td id="LC20" class="blob-code blob-code-inner js-file-line">RAM0_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>C000</td>
      </tr>
      <tr>
        <td id="L21" class="blob-num js-line-number" data-line-number="21"></td>
        <td id="LC21" class="blob-code blob-code-inner js-file-line">RAM0_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>2000</td>
      </tr>
      <tr>
        <td id="L22" class="blob-num js-line-number" data-line-number="22"></td>
        <td id="LC22" class="blob-code blob-code-inner js-file-line">ECHO_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>E000</td>
      </tr>
      <tr>
        <td id="L23" class="blob-num js-line-number" data-line-number="23"></td>
        <td id="LC23" class="blob-code blob-code-inner js-file-line">ECHO_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>1E00</td>
      </tr>
      <tr>
        <td id="L24" class="blob-num js-line-number" data-line-number="24"></td>
        <td id="LC24" class="blob-code blob-code-inner js-file-line">OAM_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>FE00</td>
      </tr>
      <tr>
        <td id="L25" class="blob-num js-line-number" data-line-number="25"></td>
        <td id="LC25" class="blob-code blob-code-inner js-file-line">OAM_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>A0</td>
      </tr>
      <tr>
        <td id="L26" class="blob-num js-line-number" data-line-number="26"></td>
        <td id="LC26" class="blob-code blob-code-inner js-file-line">IO_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>FEA0</td>
      </tr>
      <tr>
        <td id="L27" class="blob-num js-line-number" data-line-number="27"></td>
        <td id="LC27" class="blob-code blob-code-inner js-file-line">IO_SIZE			<span class="pl-k">=</span> <span class="pl-c1">0x</span>E0</td>
      </tr>
      <tr>
        <td id="L28" class="blob-num js-line-number" data-line-number="28"></td>
        <td id="LC28" class="blob-code blob-code-inner js-file-line">HRAM_START		<span class="pl-k">=</span> <span class="pl-c1">0x</span>FF80</td>
      </tr>
      <tr>
        <td id="L29" class="blob-num js-line-number" data-line-number="29"></td>
        <td id="LC29" class="blob-code blob-code-inner js-file-line">HRAM_SIZE		<span class="pl-k">=</span> <span class="pl-c1">0x</span>80</td>
      </tr>
      <tr>
        <td id="L30" class="blob-num js-line-number" data-line-number="30"></td>
        <td id="LC30" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L31" class="blob-num js-line-number" data-line-number="31"></td>
        <td id="LC31" class="blob-code blob-code-inner js-file-line"><span class="pl-k">def</span> <span class="pl-en">dwordAt</span>(<span class="pl-smi">li</span>, <span class="pl-smi">off</span>):</td>
      </tr>
      <tr>
        <td id="L32" class="blob-num js-line-number" data-line-number="32"></td>
        <td id="LC32" class="blob-code blob-code-inner js-file-line">	li.seek(off)</td>
      </tr>
      <tr>
        <td id="L33" class="blob-num js-line-number" data-line-number="33"></td>
        <td id="LC33" class="blob-code blob-code-inner js-file-line">	s <span class="pl-k">=</span> li.read(<span class="pl-c1">4</span>)</td>
      </tr>
      <tr>
        <td id="L34" class="blob-num js-line-number" data-line-number="34"></td>
        <td id="LC34" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> <span class="pl-c1">len</span>(s) <span class="pl-k">&lt;</span> <span class="pl-c1">4</span>: </td>
      </tr>
      <tr>
        <td id="L35" class="blob-num js-line-number" data-line-number="35"></td>
        <td id="LC35" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">return</span> <span class="pl-c1">0</span></td>
      </tr>
      <tr>
        <td id="L36" class="blob-num js-line-number" data-line-number="36"></td>
        <td id="LC36" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">return</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&#39;</span>&lt;I<span class="pl-pds">&#39;</span></span>, s)[<span class="pl-c1">0</span>]</td>
      </tr>
      <tr>
        <td id="L37" class="blob-num js-line-number" data-line-number="37"></td>
        <td id="LC37" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L38" class="blob-num js-line-number" data-line-number="38"></td>
        <td id="LC38" class="blob-code blob-code-inner js-file-line"><span class="pl-k">def</span> <span class="pl-en">memset_seg</span>(<span class="pl-smi">ea</span>, <span class="pl-smi">size</span>):</td>
      </tr>
      <tr>
        <td id="L39" class="blob-num js-line-number" data-line-number="39"></td>
        <td id="LC39" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">for</span> i <span class="pl-k">in</span> <span class="pl-c1">xrange</span>(<span class="pl-c1">0</span>, size):</td>
      </tr>
      <tr>
        <td id="L40" class="blob-num js-line-number" data-line-number="40"></td>
        <td id="LC40" class="blob-code blob-code-inner js-file-line">		idc.PatchByte(ea <span class="pl-k">+</span> i, <span class="pl-c1">0</span>)</td>
      </tr>
      <tr>
        <td id="L41" class="blob-num js-line-number" data-line-number="41"></td>
        <td id="LC41" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L42" class="blob-num js-line-number" data-line-number="42"></td>
        <td id="LC42" class="blob-code blob-code-inner js-file-line"><span class="pl-k">def</span> <span class="pl-en">accept_file</span>(<span class="pl-smi">li</span>, <span class="pl-smi">n</span>):</td>
      </tr>
      <tr>
        <td id="L43" class="blob-num js-line-number" data-line-number="43"></td>
        <td id="LC43" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># we support only one format per file</span></td>
      </tr>
      <tr>
        <td id="L44" class="blob-num js-line-number" data-line-number="44"></td>
        <td id="LC44" class="blob-code blob-code-inner js-file-line">    	<span class="pl-k">if</span> n <span class="pl-k">&gt;</span> <span class="pl-c1">0</span>:</td>
      </tr>
      <tr>
        <td id="L45" class="blob-num js-line-number" data-line-number="45"></td>
        <td id="LC45" class="blob-code blob-code-inner js-file-line">        	<span class="pl-k">return</span> <span class="pl-c1">0</span></td>
      </tr>
      <tr>
        <td id="L46" class="blob-num js-line-number" data-line-number="46"></td>
        <td id="LC46" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L47" class="blob-num js-line-number" data-line-number="47"></td>
        <td id="LC47" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># check the Nintendo Logo</span></td>
      </tr>
      <tr>
        <td id="L48" class="blob-num js-line-number" data-line-number="48"></td>
        <td id="LC48" class="blob-code blob-code-inner js-file-line">	li.seek(ROM_SIGNATURE_OFFSET)</td>
      </tr>
      <tr>
        <td id="L49" class="blob-num js-line-number" data-line-number="49"></td>
        <td id="LC49" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> li.read(ROM_SIGNATURE_LENGTH) <span class="pl-k">==</span> ROM_SIGNATURE:</td>
      </tr>
      <tr>
        <td id="L50" class="blob-num js-line-number" data-line-number="50"></td>
        <td id="LC50" class="blob-code blob-code-inner js-file-line">		<span class="pl-c"># accept the file</span></td>
      </tr>
      <tr>
        <td id="L51" class="blob-num js-line-number" data-line-number="51"></td>
        <td id="LC51" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">return</span> ROM_FORMAT_NAME</td>
      </tr>
      <tr>
        <td id="L52" class="blob-num js-line-number" data-line-number="52"></td>
        <td id="LC52" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L53" class="blob-num js-line-number" data-line-number="53"></td>
        <td id="LC53" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># unrecognized format</span></td>
      </tr>
      <tr>
        <td id="L54" class="blob-num js-line-number" data-line-number="54"></td>
        <td id="LC54" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">return</span> <span class="pl-c1">0</span></td>
      </tr>
      <tr>
        <td id="L55" class="blob-num js-line-number" data-line-number="55"></td>
        <td id="LC55" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L56" class="blob-num js-line-number" data-line-number="56"></td>
        <td id="LC56" class="blob-code blob-code-inner js-file-line"><span class="pl-k">def</span> <span class="pl-en">load_file</span>(<span class="pl-smi">li</span>, <span class="pl-smi">neflags</span>, <span class="pl-smi">format</span>):</td>
      </tr>
      <tr>
        <td id="L57" class="blob-num js-line-number" data-line-number="57"></td>
        <td id="LC57" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> <span class="pl-c1">format</span> <span class="pl-k">!=</span> ROM_FORMAT_NAME:</td>
      </tr>
      <tr>
        <td id="L58" class="blob-num js-line-number" data-line-number="58"></td>
        <td id="LC58" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">Warning</span>(<span class="pl-s"><span class="pl-pds">&quot;</span>Unknown format name: &#39;<span class="pl-c1">%s</span>&#39;<span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> <span class="pl-c1">format</span>)</td>
      </tr>
      <tr>
        <td id="L59" class="blob-num js-line-number" data-line-number="59"></td>
        <td id="LC59" class="blob-code blob-code-inner js-file-line">    		<span class="pl-k">return</span> <span class="pl-c1">0</span></td>
      </tr>
      <tr>
        <td id="L60" class="blob-num js-line-number" data-line-number="60"></td>
        <td id="LC60" class="blob-code blob-code-inner js-file-line">	jump <span class="pl-k">=</span> dwordAt(li, <span class="pl-c1">0</span>)</td>
      </tr>
      <tr>
        <td id="L61" class="blob-num js-line-number" data-line-number="61"></td>
        <td id="LC61" class="blob-code blob-code-inner js-file-line">	idaapi.set_processor_type(<span class="pl-s"><span class="pl-pds">&quot;</span>gb<span class="pl-pds">&quot;</span></span>, SETPROC_ALL<span class="pl-k">|</span>SETPROC_FATAL)</td>
      </tr>
      <tr>
        <td id="L62" class="blob-num js-line-number" data-line-number="62"></td>
        <td id="LC62" class="blob-code blob-code-inner js-file-line">	li.seek(<span class="pl-c1">0</span>, idaapi.SEEK_END)</td>
      </tr>
      <tr>
        <td id="L63" class="blob-num js-line-number" data-line-number="63"></td>
        <td id="LC63" class="blob-code blob-code-inner js-file-line">	size <span class="pl-k">=</span> li.tell()</td>
      </tr>
      <tr>
        <td id="L64" class="blob-num js-line-number" data-line-number="64"></td>
        <td id="LC64" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L65" class="blob-num js-line-number" data-line-number="65"></td>
        <td id="LC65" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># ROM0</span></td>
      </tr>
      <tr>
        <td id="L66" class="blob-num js-line-number" data-line-number="66"></td>
        <td id="LC66" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(ROM0_START, ROM0_START <span class="pl-k">+</span> ROM0_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L67" class="blob-num js-line-number" data-line-number="67"></td>
        <td id="LC67" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(ROM0_START, <span class="pl-s"><span class="pl-pds">&quot;</span>ROM0<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L68" class="blob-num js-line-number" data-line-number="68"></td>
        <td id="LC68" class="blob-code blob-code-inner js-file-line">	idc.SetSegmentType(ROM0_START, idc.SEG_CODE)</td>
      </tr>
      <tr>
        <td id="L69" class="blob-num js-line-number" data-line-number="69"></td>
        <td id="LC69" class="blob-code blob-code-inner js-file-line">	li.seek(<span class="pl-c1">0</span>)</td>
      </tr>
      <tr>
        <td id="L70" class="blob-num js-line-number" data-line-number="70"></td>
        <td id="LC70" class="blob-code blob-code-inner js-file-line">	li.file2base(<span class="pl-c1">0</span>, ROM0_START, ROM0_START <span class="pl-k">+</span> ROM0_SIZE, <span class="pl-c1">0</span>)</td>
      </tr>
      <tr>
        <td id="L71" class="blob-num js-line-number" data-line-number="71"></td>
        <td id="LC71" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L72" class="blob-num js-line-number" data-line-number="72"></td>
        <td id="LC72" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># ROM1</span></td>
      </tr>
      <tr>
        <td id="L73" class="blob-num js-line-number" data-line-number="73"></td>
        <td id="LC73" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(ROM1_START, ROM1_START <span class="pl-k">+</span> ROM1_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L74" class="blob-num js-line-number" data-line-number="74"></td>
        <td id="LC74" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(ROM1_START, <span class="pl-s"><span class="pl-pds">&quot;</span>ROM1<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L75" class="blob-num js-line-number" data-line-number="75"></td>
        <td id="LC75" class="blob-code blob-code-inner js-file-line">	idc.SetSegmentType(ROM1_START, idc.SEG_CODE)</td>
      </tr>
      <tr>
        <td id="L76" class="blob-num js-line-number" data-line-number="76"></td>
        <td id="LC76" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L77" class="blob-num js-line-number" data-line-number="77"></td>
        <td id="LC77" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># VRAM</span></td>
      </tr>
      <tr>
        <td id="L78" class="blob-num js-line-number" data-line-number="78"></td>
        <td id="LC78" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(VRAM_START, VRAM_START <span class="pl-k">+</span> VRAM_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L79" class="blob-num js-line-number" data-line-number="79"></td>
        <td id="LC79" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(VRAM_START, <span class="pl-s"><span class="pl-pds">&quot;</span>VRAM<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L80" class="blob-num js-line-number" data-line-number="80"></td>
        <td id="LC80" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L81" class="blob-num js-line-number" data-line-number="81"></td>
        <td id="LC81" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># RAM1</span></td>
      </tr>
      <tr>
        <td id="L82" class="blob-num js-line-number" data-line-number="82"></td>
        <td id="LC82" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(RAM1_START, RAM1_START <span class="pl-k">+</span> RAM1_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L83" class="blob-num js-line-number" data-line-number="83"></td>
        <td id="LC83" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(RAM1_START, <span class="pl-s"><span class="pl-pds">&quot;</span>RAM1<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L84" class="blob-num js-line-number" data-line-number="84"></td>
        <td id="LC84" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L85" class="blob-num js-line-number" data-line-number="85"></td>
        <td id="LC85" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># RAM0</span></td>
      </tr>
      <tr>
        <td id="L86" class="blob-num js-line-number" data-line-number="86"></td>
        <td id="LC86" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(RAM0_START, RAM0_START <span class="pl-k">+</span> RAM0_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L87" class="blob-num js-line-number" data-line-number="87"></td>
        <td id="LC87" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(RAM0_START, <span class="pl-s"><span class="pl-pds">&quot;</span>RAM0<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L88" class="blob-num js-line-number" data-line-number="88"></td>
        <td id="LC88" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L89" class="blob-num js-line-number" data-line-number="89"></td>
        <td id="LC89" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># ECHO</span></td>
      </tr>
      <tr>
        <td id="L90" class="blob-num js-line-number" data-line-number="90"></td>
        <td id="LC90" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(ECHO_START, ECHO_START <span class="pl-k">+</span> ECHO_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L91" class="blob-num js-line-number" data-line-number="91"></td>
        <td id="LC91" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(ECHO_START, <span class="pl-s"><span class="pl-pds">&quot;</span>ECHO<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L92" class="blob-num js-line-number" data-line-number="92"></td>
        <td id="LC92" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L93" class="blob-num js-line-number" data-line-number="93"></td>
        <td id="LC93" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># OAM</span></td>
      </tr>
      <tr>
        <td id="L94" class="blob-num js-line-number" data-line-number="94"></td>
        <td id="LC94" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(OAM_START, OAM_START <span class="pl-k">+</span> OAM_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L95" class="blob-num js-line-number" data-line-number="95"></td>
        <td id="LC95" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(OAM_START, <span class="pl-s"><span class="pl-pds">&quot;</span>OAM<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L96" class="blob-num js-line-number" data-line-number="96"></td>
        <td id="LC96" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L97" class="blob-num js-line-number" data-line-number="97"></td>
        <td id="LC97" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># IO</span></td>
      </tr>
      <tr>
        <td id="L98" class="blob-num js-line-number" data-line-number="98"></td>
        <td id="LC98" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(IO_START, IO_START <span class="pl-k">+</span> IO_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L99" class="blob-num js-line-number" data-line-number="99"></td>
        <td id="LC99" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(IO_START, <span class="pl-s"><span class="pl-pds">&quot;</span>IO<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L100" class="blob-num js-line-number" data-line-number="100"></td>
        <td id="LC100" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L101" class="blob-num js-line-number" data-line-number="101"></td>
        <td id="LC101" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># HRAM</span></td>
      </tr>
      <tr>
        <td id="L102" class="blob-num js-line-number" data-line-number="102"></td>
        <td id="LC102" class="blob-code blob-code-inner js-file-line">	idc.AddSeg(HRAM_START, HRAM_START <span class="pl-k">+</span> HRAM_SIZE, <span class="pl-c1">0</span>, <span class="pl-c1">0</span>, idaapi.saRelPara, idaapi.scPub)</td>
      </tr>
      <tr>
        <td id="L103" class="blob-num js-line-number" data-line-number="103"></td>
        <td id="LC103" class="blob-code blob-code-inner js-file-line">	idc.RenameSeg(HRAM_START, <span class="pl-s"><span class="pl-pds">&quot;</span>HRAM<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L104" class="blob-num js-line-number" data-line-number="104"></td>
        <td id="LC104" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L105" class="blob-num js-line-number" data-line-number="105"></td>
        <td id="LC105" class="blob-code blob-code-inner js-file-line">	header_info(li)</td>
      </tr>
      <tr>
        <td id="L106" class="blob-num js-line-number" data-line-number="106"></td>
        <td id="LC106" class="blob-code blob-code-inner js-file-line">	naming()</td>
      </tr>
      <tr>
        <td id="L107" class="blob-num js-line-number" data-line-number="107"></td>
        <td id="LC107" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">print</span>(<span class="pl-s"><span class="pl-pds">&quot;</span>[+] Load OK<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L108" class="blob-num js-line-number" data-line-number="108"></td>
        <td id="LC108" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">return</span> <span class="pl-c1">1</span></td>
      </tr>
      <tr>
        <td id="L109" class="blob-num js-line-number" data-line-number="109"></td>
        <td id="LC109" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L110" class="blob-num js-line-number" data-line-number="110"></td>
        <td id="LC110" class="blob-code blob-code-inner js-file-line"><span class="pl-k">def</span> <span class="pl-en">header_info</span>(<span class="pl-smi">li</span>):</td>
      </tr>
      <tr>
        <td id="L111" class="blob-num js-line-number" data-line-number="111"></td>
        <td id="LC111" class="blob-code blob-code-inner js-file-line">	idaapi.add_long_cmt(<span class="pl-c1">0</span>, <span class="pl-c1">True</span>, <span class="pl-s"><span class="pl-pds">&quot;</span>-------------------------------<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L112" class="blob-num js-line-number" data-line-number="112"></td>
        <td id="LC112" class="blob-code blob-code-inner js-file-line">	li.seek(<span class="pl-c1">0x</span>100)</td>
      </tr>
      <tr>
        <td id="L113" class="blob-num js-line-number" data-line-number="113"></td>
        <td id="LC113" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">1</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; ROM HEADER<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L114" class="blob-num js-line-number" data-line-number="114"></td>
        <td id="LC114" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">2</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Entry Point : <span class="pl-c1">%04X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> (struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;I<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">4</span>))[<span class="pl-c1">0</span>] <span class="pl-k">&gt;&gt;</span> <span class="pl-c1">0x</span>10))</td>
      </tr>
      <tr>
        <td id="L115" class="blob-num js-line-number" data-line-number="115"></td>
        <td id="LC115" class="blob-code blob-code-inner js-file-line">	li.read(<span class="pl-c1">0x</span>30)</td>
      </tr>
      <tr>
        <td id="L116" class="blob-num js-line-number" data-line-number="116"></td>
        <td id="LC116" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">3</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; TITLE : <span class="pl-c1">%s</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> li.read(<span class="pl-c1">0x</span>F))</td>
      </tr>
      <tr>
        <td id="L117" class="blob-num js-line-number" data-line-number="117"></td>
        <td id="LC117" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">4</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Manufacturer Code : <span class="pl-c1">%s</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> li.read(<span class="pl-c1">4</span>))</td>
      </tr>
      <tr>
        <td id="L118" class="blob-num js-line-number" data-line-number="118"></td>
        <td id="LC118" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">5</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; CGB Flag : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L119" class="blob-num js-line-number" data-line-number="119"></td>
        <td id="LC119" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">6</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; New Licensee Code : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L120" class="blob-num js-line-number" data-line-number="120"></td>
        <td id="LC120" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">7</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; SGB Flag : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L121" class="blob-num js-line-number" data-line-number="121"></td>
        <td id="LC121" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">8</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Cartridge Type : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L122" class="blob-num js-line-number" data-line-number="122"></td>
        <td id="LC122" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">9</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; ROM Size : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L123" class="blob-num js-line-number" data-line-number="123"></td>
        <td id="LC123" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">10</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; RAM Size : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L124" class="blob-num js-line-number" data-line-number="124"></td>
        <td id="LC124" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">11</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Destination Code : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L125" class="blob-num js-line-number" data-line-number="125"></td>
        <td id="LC125" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">12</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Old license Code : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L126" class="blob-num js-line-number" data-line-number="126"></td>
        <td id="LC126" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">13</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Mask ROM Version number : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L127" class="blob-num js-line-number" data-line-number="127"></td>
        <td id="LC127" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">14</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Header Checksum : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L128" class="blob-num js-line-number" data-line-number="128"></td>
        <td id="LC128" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">15</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>; Global Checksum : <span class="pl-c1">%02X</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">%</span> struct.unpack(<span class="pl-s"><span class="pl-pds">&quot;</span>&lt;B<span class="pl-pds">&quot;</span></span>, li.read(<span class="pl-c1">1</span>))[<span class="pl-c1">0</span>])</td>
      </tr>
      <tr>
        <td id="L129" class="blob-num js-line-number" data-line-number="129"></td>
        <td id="LC129" class="blob-code blob-code-inner js-file-line">	idc.ExtLinA(<span class="pl-c1">0</span>, <span class="pl-c1">16</span>,  <span class="pl-s"><span class="pl-pds">&quot;</span>-------------------------------<span class="pl-pds">&quot;</span></span>)</td>
      </tr>
      <tr>
        <td id="L130" class="blob-num js-line-number" data-line-number="130"></td>
        <td id="LC130" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L131" class="blob-num js-line-number" data-line-number="131"></td>
        <td id="LC131" class="blob-code blob-code-inner js-file-line"><span class="pl-k">def</span> <span class="pl-en">naming</span>():</td>
      </tr>
      <tr>
        <td id="L132" class="blob-num js-line-number" data-line-number="132"></td>
        <td id="LC132" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF40, <span class="pl-s"><span class="pl-pds">&quot;</span>LCD_Control<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L133" class="blob-num js-line-number" data-line-number="133"></td>
        <td id="LC133" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF40)</td>
      </tr>
      <tr>
        <td id="L134" class="blob-num js-line-number" data-line-number="134"></td>
        <td id="LC134" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF41, <span class="pl-s"><span class="pl-pds">&quot;</span>LCD_Status<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L135" class="blob-num js-line-number" data-line-number="135"></td>
        <td id="LC135" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF41)</td>
      </tr>
      <tr>
        <td id="L136" class="blob-num js-line-number" data-line-number="136"></td>
        <td id="LC136" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF42, <span class="pl-s"><span class="pl-pds">&quot;</span>SCY<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L137" class="blob-num js-line-number" data-line-number="137"></td>
        <td id="LC137" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF42)</td>
      </tr>
      <tr>
        <td id="L138" class="blob-num js-line-number" data-line-number="138"></td>
        <td id="LC138" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF43, <span class="pl-s"><span class="pl-pds">&quot;</span>SCX<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L139" class="blob-num js-line-number" data-line-number="139"></td>
        <td id="LC139" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF43)</td>
      </tr>
      <tr>
        <td id="L140" class="blob-num js-line-number" data-line-number="140"></td>
        <td id="LC140" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF44, <span class="pl-s"><span class="pl-pds">&quot;</span>LY<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L141" class="blob-num js-line-number" data-line-number="141"></td>
        <td id="LC141" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF44)</td>
      </tr>
      <tr>
        <td id="L142" class="blob-num js-line-number" data-line-number="142"></td>
        <td id="LC142" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF45, <span class="pl-s"><span class="pl-pds">&quot;</span>LYC<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L143" class="blob-num js-line-number" data-line-number="143"></td>
        <td id="LC143" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF45)</td>
      </tr>
      <tr>
        <td id="L144" class="blob-num js-line-number" data-line-number="144"></td>
        <td id="LC144" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF4A, <span class="pl-s"><span class="pl-pds">&quot;</span>WY<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L145" class="blob-num js-line-number" data-line-number="145"></td>
        <td id="LC145" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF4A)</td>
      </tr>
      <tr>
        <td id="L146" class="blob-num js-line-number" data-line-number="146"></td>
        <td id="LC146" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF4B, <span class="pl-s"><span class="pl-pds">&quot;</span>WX<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L147" class="blob-num js-line-number" data-line-number="147"></td>
        <td id="LC147" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF4B)</td>
      </tr>
      <tr>
        <td id="L148" class="blob-num js-line-number" data-line-number="148"></td>
        <td id="LC148" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF47, <span class="pl-s"><span class="pl-pds">&quot;</span>BGP<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L149" class="blob-num js-line-number" data-line-number="149"></td>
        <td id="LC149" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF47)	</td>
      </tr>
      <tr>
        <td id="L150" class="blob-num js-line-number" data-line-number="150"></td>
        <td id="LC150" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF48, <span class="pl-s"><span class="pl-pds">&quot;</span>OBP0<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L151" class="blob-num js-line-number" data-line-number="151"></td>
        <td id="LC151" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF48)</td>
      </tr>
      <tr>
        <td id="L152" class="blob-num js-line-number" data-line-number="152"></td>
        <td id="LC152" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF49, <span class="pl-s"><span class="pl-pds">&quot;</span>OBP1<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L153" class="blob-num js-line-number" data-line-number="153"></td>
        <td id="LC153" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF49)</td>
      </tr>
      <tr>
        <td id="L154" class="blob-num js-line-number" data-line-number="154"></td>
        <td id="LC154" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF68, <span class="pl-s"><span class="pl-pds">&quot;</span>BCPS<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L155" class="blob-num js-line-number" data-line-number="155"></td>
        <td id="LC155" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF68)</td>
      </tr>
      <tr>
        <td id="L156" class="blob-num js-line-number" data-line-number="156"></td>
        <td id="LC156" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF69, <span class="pl-s"><span class="pl-pds">&quot;</span>BCPD<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L157" class="blob-num js-line-number" data-line-number="157"></td>
        <td id="LC157" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF69)</td>
      </tr>
      <tr>
        <td id="L158" class="blob-num js-line-number" data-line-number="158"></td>
        <td id="LC158" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF6A, <span class="pl-s"><span class="pl-pds">&quot;</span>OCPS<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L159" class="blob-num js-line-number" data-line-number="159"></td>
        <td id="LC159" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF6A)</td>
      </tr>
      <tr>
        <td id="L160" class="blob-num js-line-number" data-line-number="160"></td>
        <td id="LC160" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF6B, <span class="pl-s"><span class="pl-pds">&quot;</span>OCPD<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L161" class="blob-num js-line-number" data-line-number="161"></td>
        <td id="LC161" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF6B)</td>
      </tr>
      <tr>
        <td id="L162" class="blob-num js-line-number" data-line-number="162"></td>
        <td id="LC162" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF4F, <span class="pl-s"><span class="pl-pds">&quot;</span>VBK<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L163" class="blob-num js-line-number" data-line-number="163"></td>
        <td id="LC163" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF4F)</td>
      </tr>
      <tr>
        <td id="L164" class="blob-num js-line-number" data-line-number="164"></td>
        <td id="LC164" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF46, <span class="pl-s"><span class="pl-pds">&quot;</span>DMA<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L165" class="blob-num js-line-number" data-line-number="165"></td>
        <td id="LC165" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF46)</td>
      </tr>
      <tr>
        <td id="L166" class="blob-num js-line-number" data-line-number="166"></td>
        <td id="LC166" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF51, <span class="pl-s"><span class="pl-pds">&quot;</span>HDMA1<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L167" class="blob-num js-line-number" data-line-number="167"></td>
        <td id="LC167" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF51)</td>
      </tr>
      <tr>
        <td id="L168" class="blob-num js-line-number" data-line-number="168"></td>
        <td id="LC168" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF52, <span class="pl-s"><span class="pl-pds">&quot;</span>HDMA2<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L169" class="blob-num js-line-number" data-line-number="169"></td>
        <td id="LC169" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF52)</td>
      </tr>
      <tr>
        <td id="L170" class="blob-num js-line-number" data-line-number="170"></td>
        <td id="LC170" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF53, <span class="pl-s"><span class="pl-pds">&quot;</span>HDMA3<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L171" class="blob-num js-line-number" data-line-number="171"></td>
        <td id="LC171" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF53)</td>
      </tr>
      <tr>
        <td id="L172" class="blob-num js-line-number" data-line-number="172"></td>
        <td id="LC172" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF54, <span class="pl-s"><span class="pl-pds">&quot;</span>HDMA4<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L173" class="blob-num js-line-number" data-line-number="173"></td>
        <td id="LC173" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF54)</td>
      </tr>
      <tr>
        <td id="L174" class="blob-num js-line-number" data-line-number="174"></td>
        <td id="LC174" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF55, <span class="pl-s"><span class="pl-pds">&quot;</span>HDMA5<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L175" class="blob-num js-line-number" data-line-number="175"></td>
        <td id="LC175" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF55)</td>
      </tr>
      <tr>
        <td id="L176" class="blob-num js-line-number" data-line-number="176"></td>
        <td id="LC176" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF10, <span class="pl-s"><span class="pl-pds">&quot;</span>NR10<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L177" class="blob-num js-line-number" data-line-number="177"></td>
        <td id="LC177" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF10)</td>
      </tr>
      <tr>
        <td id="L178" class="blob-num js-line-number" data-line-number="178"></td>
        <td id="LC178" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF11, <span class="pl-s"><span class="pl-pds">&quot;</span>NR11<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L179" class="blob-num js-line-number" data-line-number="179"></td>
        <td id="LC179" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF11)</td>
      </tr>
      <tr>
        <td id="L180" class="blob-num js-line-number" data-line-number="180"></td>
        <td id="LC180" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF12, <span class="pl-s"><span class="pl-pds">&quot;</span>NR12<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L181" class="blob-num js-line-number" data-line-number="181"></td>
        <td id="LC181" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF12)</td>
      </tr>
      <tr>
        <td id="L182" class="blob-num js-line-number" data-line-number="182"></td>
        <td id="LC182" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF13, <span class="pl-s"><span class="pl-pds">&quot;</span>NR13<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L183" class="blob-num js-line-number" data-line-number="183"></td>
        <td id="LC183" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF13)</td>
      </tr>
      <tr>
        <td id="L184" class="blob-num js-line-number" data-line-number="184"></td>
        <td id="LC184" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF14, <span class="pl-s"><span class="pl-pds">&quot;</span>NR14<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L185" class="blob-num js-line-number" data-line-number="185"></td>
        <td id="LC185" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF14)</td>
      </tr>
      <tr>
        <td id="L186" class="blob-num js-line-number" data-line-number="186"></td>
        <td id="LC186" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF16, <span class="pl-s"><span class="pl-pds">&quot;</span>NR21<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L187" class="blob-num js-line-number" data-line-number="187"></td>
        <td id="LC187" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF16)</td>
      </tr>
      <tr>
        <td id="L188" class="blob-num js-line-number" data-line-number="188"></td>
        <td id="LC188" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF17, <span class="pl-s"><span class="pl-pds">&quot;</span>NR22<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L189" class="blob-num js-line-number" data-line-number="189"></td>
        <td id="LC189" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF17)</td>
      </tr>
      <tr>
        <td id="L190" class="blob-num js-line-number" data-line-number="190"></td>
        <td id="LC190" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF18, <span class="pl-s"><span class="pl-pds">&quot;</span>NR23<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L191" class="blob-num js-line-number" data-line-number="191"></td>
        <td id="LC191" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF18)</td>
      </tr>
      <tr>
        <td id="L192" class="blob-num js-line-number" data-line-number="192"></td>
        <td id="LC192" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF19, <span class="pl-s"><span class="pl-pds">&quot;</span>NR24<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L193" class="blob-num js-line-number" data-line-number="193"></td>
        <td id="LC193" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF19)</td>
      </tr>
      <tr>
        <td id="L194" class="blob-num js-line-number" data-line-number="194"></td>
        <td id="LC194" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF1A, <span class="pl-s"><span class="pl-pds">&quot;</span>NR30<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L195" class="blob-num js-line-number" data-line-number="195"></td>
        <td id="LC195" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF1A)</td>
      </tr>
      <tr>
        <td id="L196" class="blob-num js-line-number" data-line-number="196"></td>
        <td id="LC196" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF1B, <span class="pl-s"><span class="pl-pds">&quot;</span>NR31<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L197" class="blob-num js-line-number" data-line-number="197"></td>
        <td id="LC197" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF1B)</td>
      </tr>
      <tr>
        <td id="L198" class="blob-num js-line-number" data-line-number="198"></td>
        <td id="LC198" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF1C, <span class="pl-s"><span class="pl-pds">&quot;</span>NR32<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L199" class="blob-num js-line-number" data-line-number="199"></td>
        <td id="LC199" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF1C)</td>
      </tr>
      <tr>
        <td id="L200" class="blob-num js-line-number" data-line-number="200"></td>
        <td id="LC200" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF1D, <span class="pl-s"><span class="pl-pds">&quot;</span>NR33<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L201" class="blob-num js-line-number" data-line-number="201"></td>
        <td id="LC201" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF1D)</td>
      </tr>
      <tr>
        <td id="L202" class="blob-num js-line-number" data-line-number="202"></td>
        <td id="LC202" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF1E, <span class="pl-s"><span class="pl-pds">&quot;</span>NR34<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L203" class="blob-num js-line-number" data-line-number="203"></td>
        <td id="LC203" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF1E)</td>
      </tr>
      <tr>
        <td id="L204" class="blob-num js-line-number" data-line-number="204"></td>
        <td id="LC204" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF20, <span class="pl-s"><span class="pl-pds">&quot;</span>NR41<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L205" class="blob-num js-line-number" data-line-number="205"></td>
        <td id="LC205" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF20)</td>
      </tr>
      <tr>
        <td id="L206" class="blob-num js-line-number" data-line-number="206"></td>
        <td id="LC206" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF21, <span class="pl-s"><span class="pl-pds">&quot;</span>NR42<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L207" class="blob-num js-line-number" data-line-number="207"></td>
        <td id="LC207" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF21)</td>
      </tr>
      <tr>
        <td id="L208" class="blob-num js-line-number" data-line-number="208"></td>
        <td id="LC208" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF22, <span class="pl-s"><span class="pl-pds">&quot;</span>NR43<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L209" class="blob-num js-line-number" data-line-number="209"></td>
        <td id="LC209" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF22)</td>
      </tr>
      <tr>
        <td id="L210" class="blob-num js-line-number" data-line-number="210"></td>
        <td id="LC210" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF23, <span class="pl-s"><span class="pl-pds">&quot;</span>NR44<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L211" class="blob-num js-line-number" data-line-number="211"></td>
        <td id="LC211" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF23)</td>
      </tr>
      <tr>
        <td id="L212" class="blob-num js-line-number" data-line-number="212"></td>
        <td id="LC212" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF24, <span class="pl-s"><span class="pl-pds">&quot;</span>NR50<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L213" class="blob-num js-line-number" data-line-number="213"></td>
        <td id="LC213" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF24)</td>
      </tr>
      <tr>
        <td id="L214" class="blob-num js-line-number" data-line-number="214"></td>
        <td id="LC214" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF25, <span class="pl-s"><span class="pl-pds">&quot;</span>NR51<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L215" class="blob-num js-line-number" data-line-number="215"></td>
        <td id="LC215" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF25)</td>
      </tr>
      <tr>
        <td id="L216" class="blob-num js-line-number" data-line-number="216"></td>
        <td id="LC216" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF26, <span class="pl-s"><span class="pl-pds">&quot;</span>NR52<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L217" class="blob-num js-line-number" data-line-number="217"></td>
        <td id="LC217" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF26)</td>
      </tr>
      <tr>
        <td id="L218" class="blob-num js-line-number" data-line-number="218"></td>
        <td id="LC218" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF00, <span class="pl-s"><span class="pl-pds">&quot;</span>JOYP<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L219" class="blob-num js-line-number" data-line-number="219"></td>
        <td id="LC219" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF00)</td>
      </tr>
      <tr>
        <td id="L220" class="blob-num js-line-number" data-line-number="220"></td>
        <td id="LC220" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF01, <span class="pl-s"><span class="pl-pds">&quot;</span>SB<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L221" class="blob-num js-line-number" data-line-number="221"></td>
        <td id="LC221" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF01)</td>
      </tr>
      <tr>
        <td id="L222" class="blob-num js-line-number" data-line-number="222"></td>
        <td id="LC222" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF02, <span class="pl-s"><span class="pl-pds">&quot;</span>SC<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L223" class="blob-num js-line-number" data-line-number="223"></td>
        <td id="LC223" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF02)</td>
      </tr>
      <tr>
        <td id="L224" class="blob-num js-line-number" data-line-number="224"></td>
        <td id="LC224" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF04, <span class="pl-s"><span class="pl-pds">&quot;</span>DIV<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L225" class="blob-num js-line-number" data-line-number="225"></td>
        <td id="LC225" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF04)</td>
      </tr>
      <tr>
        <td id="L226" class="blob-num js-line-number" data-line-number="226"></td>
        <td id="LC226" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF05, <span class="pl-s"><span class="pl-pds">&quot;</span>TIMA<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L227" class="blob-num js-line-number" data-line-number="227"></td>
        <td id="LC227" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF05)</td>
      </tr>
      <tr>
        <td id="L228" class="blob-num js-line-number" data-line-number="228"></td>
        <td id="LC228" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF06, <span class="pl-s"><span class="pl-pds">&quot;</span>TMA<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L229" class="blob-num js-line-number" data-line-number="229"></td>
        <td id="LC229" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF06)</td>
      </tr>
      <tr>
        <td id="L230" class="blob-num js-line-number" data-line-number="230"></td>
        <td id="LC230" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF07, <span class="pl-s"><span class="pl-pds">&quot;</span>TAC<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L231" class="blob-num js-line-number" data-line-number="231"></td>
        <td id="LC231" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF07)</td>
      </tr>
      <tr>
        <td id="L232" class="blob-num js-line-number" data-line-number="232"></td>
        <td id="LC232" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FFFF, <span class="pl-s"><span class="pl-pds">&quot;</span>IE<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L233" class="blob-num js-line-number" data-line-number="233"></td>
        <td id="LC233" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FFFF)</td>
      </tr>
      <tr>
        <td id="L234" class="blob-num js-line-number" data-line-number="234"></td>
        <td id="LC234" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF0F, <span class="pl-s"><span class="pl-pds">&quot;</span>IF<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L235" class="blob-num js-line-number" data-line-number="235"></td>
        <td id="LC235" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF0F)</td>
      </tr>
      <tr>
        <td id="L236" class="blob-num js-line-number" data-line-number="236"></td>
        <td id="LC236" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF4D, <span class="pl-s"><span class="pl-pds">&quot;</span>KEY1<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L237" class="blob-num js-line-number" data-line-number="237"></td>
        <td id="LC237" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF4D)</td>
      </tr>
      <tr>
        <td id="L238" class="blob-num js-line-number" data-line-number="238"></td>
        <td id="LC238" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF56, <span class="pl-s"><span class="pl-pds">&quot;</span>RP<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L239" class="blob-num js-line-number" data-line-number="239"></td>
        <td id="LC239" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF56)</td>
      </tr>
      <tr>
        <td id="L240" class="blob-num js-line-number" data-line-number="240"></td>
        <td id="LC240" class="blob-code blob-code-inner js-file-line">	MakeNameEx(<span class="pl-c1">0x</span>FF70, <span class="pl-s"><span class="pl-pds">&quot;</span>SVBK<span class="pl-pds">&quot;</span></span>, SN_NOCHECK <span class="pl-k">|</span> SN_NOWARN)</td>
      </tr>
      <tr>
        <td id="L241" class="blob-num js-line-number" data-line-number="241"></td>
        <td id="LC241" class="blob-code blob-code-inner js-file-line">	MakeByte(<span class="pl-c1">0x</span>FF70)</td>
      </tr>
      <tr>
        <td id="L242" class="blob-num js-line-number" data-line-number="242"></td>
        <td id="LC242" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L243" class="blob-num js-line-number" data-line-number="243"></td>
        <td id="LC243" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L244" class="blob-num js-line-number" data-line-number="244"></td>
        <td id="LC244" class="blob-code blob-code-inner js-file-line"><span class="pl-k">def</span> <span class="pl-en">main</span>():</td>
      </tr>
      <tr>
        <td id="L245" class="blob-num js-line-number" data-line-number="245"></td>
        <td id="LC245" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">return</span> <span class="pl-c1">0</span></td>
      </tr>
</table>

  </div>

</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="" class="js-jump-to-line-form" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" aria-label="Jump to line" autofocus>
    <button type="submit" class="btn">Go</button>
</form></div>

        </div>
      </div>
      <div class="modal-backdrop"></div>
    </div>
  </div>


    </div>

      <div class="container">
  <div class="site-footer" role="contentinfo">
    <ul class="site-footer-links right">
        <li><a href="https://status.github.com/" data-ga-click="Footer, go to status, text:status">Status</a></li>
      <li><a href="https://developer.github.com" data-ga-click="Footer, go to api, text:api">API</a></li>
      <li><a href="https://training.github.com" data-ga-click="Footer, go to training, text:training">Training</a></li>
      <li><a href="https://shop.github.com" data-ga-click="Footer, go to shop, text:shop">Shop</a></li>
        <li><a href="https://github.com/blog" data-ga-click="Footer, go to blog, text:blog">Blog</a></li>
        <li><a href="https://github.com/about" data-ga-click="Footer, go to about, text:about">About</a></li>
        <li><a href="https://github.com/pricing" data-ga-click="Footer, go to pricing, text:pricing">Pricing</a></li>

    </ul>

    <a href="https://github.com" aria-label="Homepage">
      <span class="mega-octicon octicon-mark-github" title="GitHub"></span>
</a>
    <ul class="site-footer-links">
      <li>&copy; 2015 <span title="0.04767s from github-fe119-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="https://github.com/site/terms" data-ga-click="Footer, go to terms, text:terms">Terms</a></li>
        <li><a href="https://github.com/site/privacy" data-ga-click="Footer, go to privacy, text:privacy">Privacy</a></li>
        <li><a href="https://github.com/security" data-ga-click="Footer, go to security, text:security">Security</a></li>
        <li><a href="https://github.com/contact" data-ga-click="Footer, go to contact, text:contact">Contact</a></li>
        <li><a href="https://help.github.com" data-ga-click="Footer, go to help, text:help">Help</a></li>
    </ul>
  </div>
</div>



    
    
    

    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <button type="button" class="flash-close js-flash-close js-ajax-error-dismiss" aria-label="Dismiss error">
        <span class="octicon octicon-x"></span>
      </button>
      Something went wrong with that request. Please try again.
    </div>


      <script crossorigin="anonymous" src="https://assets-cdn.github.com/assets/frameworks-7d180c2bb5779ecb7ab5d04ce8af999e73836dcf0df1a8c44b69c62a1de0732f.js"></script>
      <script async="async" crossorigin="anonymous" src="https://assets-cdn.github.com/assets/github-0430146da495323855e2f392d5359490e0aebbd7562599ad397ec9dedade4e0e.js"></script>
      
      
    <div class="js-stale-session-flash stale-session-flash flash flash-warn flash-banner hidden">
      <span class="octicon octicon-alert"></span>
      <span class="signed-in-tab-flash">You signed in with another tab or window. <a href="">Reload</a> to refresh your session.</span>
      <span class="signed-out-tab-flash">You signed out in another tab or window. <a href="">Reload</a> to refresh your session.</span>
    </div>
  </body>
</html>

