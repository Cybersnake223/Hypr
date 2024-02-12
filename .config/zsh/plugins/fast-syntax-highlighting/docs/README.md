<h1 align="center"><p>
  <a title="❮ Zi ❯" target="_self" href="https://github.com/z-shell/zi">
  <img width="60px" height="60px" src="https://raw.githubusercontent.com/z-shell/zi/main/docs/images/logo.png" alt="Logo" /></a>
    ❮ Zi ❯ - F-Sy-H</p></h1>
<h2 align="center">Feature-rich Syntax Highlighting for Zsh</h2>
<p align="center">
  <a href="https://github.com/orgs/z-shell/discussions/">《❔ Ask a Question 》</a>
  <a href="https://wiki.zshell.dev.dev/search">《💡 Search Wiki 》</a>
  <a href="https://github.com/z-shell/community/issues/new?assignees=&labels=%F0%9F%91%A5+member&template=membership.yml&title=team%3A+">《💜 Join 》</a>
  <a href="https://translate.zshell.dev">《🌐 Localize 》</a>
</p>
<p align="center">
<a target="_self" href="https://translate.zshell.dev">
  <img align="center" src="https://badges.crowdin.net/e/f108c12713ee8526ac878d5671ad6e29/localized.svg" />
</a>
<a href="https://github.com/z-shell/f-sy-h/actions/workflows/zunit.yml">
  <img align="center" src="https://github.com/z-shell/f-sy-h/actions/workflows/zunit.yml/badge.svg" alt="✅ ZUnit" />
</a>
<a href="https://github.com/z-shell/F-Sy-H/actions/workflows/zsh-n.yml">
  <img align="center" src="https://github.com/z-shell/F-Sy-H/actions/workflows/zsh-n.yml/badge.svg" alt="✅ Zsh Parse" />
</a>
<a href="https://github.com/z-shell/F-Sy-H/actions/workflows/trunk-check.yml">
  <img align="center" src="https://github.com/z-shell/F-Sy-H/actions/workflows/trunk-check.yml/badge.svg" alt="⭕ Trunk" />
</a>
<a title="VIM" target="_self" href="https://github.com/z-shell/zi-vim-syntax/">
  <img align="center" src="https://img.shields.io/badge/--019733?logo=vim" alt="VIM" />
</a>
<a title="ZW" target="_self" href="https://open.vscode.dev/z-shell/f-sy-h/">
  <img align="center" src="https://img.shields.io/badge/--007ACC?logo=visual%20studio%20code&logoColor=ffffff" alt="Visual Studio Code" /></a></p><hr />
<p align="center">
<img align="center" width="80%" height="auto" src="https://raw.githubusercontent.com/z-shell/.github/main/metrics/plugin/followup/f-sy-h_followup.svg" />
  <img align="center" width="80%" height="auto" src="https://raw.githubusercontent.com/z-shell/.github/main/metrics/plugin/metrics.svg" />
<hr /><h2 align="left">Related</h2>
<ul>
  <li><a href="../LICENSE">License</a></li>
  <li><a href="CHANGELOG.md">Changelog</a></li>
  <li><a href="THEME_GUIDE.md">Theme Guide</a></li>
  <li><a href="CHROMA_GUIDE.adoc">Chroma Guide</a></li>
</ul>
<hr /> <h2 align="left">Installation</h2>

  <hr /><h3 align="left">Manual</h3>

  <p>Clone the Repository.</p>

<pre><code class="lang-zsh">git clone https://github.<span class="hljs-keyword">com</span>/<span class="hljs-keyword">z</span>-<span class="hljs-keyword">shell</span>/F-Sy-H ~/path/<span class="hljs-keyword">to</span>/f-sy-h</code></pre>

  <p>And add the following to your `zshrc` file.</p>

<pre><code class="lang-zsh"><span class="hljs-keyword">source</span> ~<span class="hljs-regexp">/path/</span>to<span class="hljs-regexp">/f-sy-h/</span>F-Sy-H.plugin.zsh</code></pre>

<hr /><h3 align="left">Zi</h3>

  <p>Add the following to your `zshrc` file.</p>

<pre><code class="lang-zsh">zi light z-<span class="hljs-keyword">shell</span>/F-Sy-H</code></pre>

<p> Here's an example of how to load the plugin together with a few other popular ones with the use of
 <a href="https://wiki.zhsell.dev/docs/getting_started/overview#turbo-mode-zsh--53">turbo mode</a></p>
<p>i.e.: speeding up the Zsh startup by loading the plugin right after the first prompt, in background: </p>

  <pre><code class="lang-zsh">zi wait lucid <span class="hljs-keyword">for</span> <span class="hljs-string">\</span>
  atinit<span class="hljs-string">"ZI[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"</span> <span class="hljs-string">\</span>
     z-shell/F-Sy-H <span class="hljs-string">\</span>
  blockf <span class="hljs-string">\</span>
     zsh-users/zsh-completions <span class="hljs-string">\</span>
  atload<span class="hljs-string">"!_zsh_autosuggest_start"</span> <span class="hljs-string">\</span>
     zsh-users/zsh-autosuggestions
 </code></pre>

  <hr /><h3 align="left">Zinit</h3>

  <p>Add the following to your `zshrc` file.</p>

<pre><code class="lang-zsh">zinit light z-<span class="hljs-keyword">shell</span>/F-Sy-H</code></pre>

  <hr /><h3 align="left">Antigen</h3>

  <p>Add the following to your `zshrc` file.</p>

<pre><code class="lang-zsh">antigen bundle z-<span class="hljs-keyword">shell</span>/F-Sy-H --branch=main</code></pre>

  <hr /><h3 align="left">Zgen</h3>

<p>Add the following to your <code>.zshrc</code> file in the same place you&#39;re doing your other <code>zgen load</code> calls in.</p>

  <pre><code class="lang-zsh">zgen <span class="hljs-keyword">load</span> z-<span class="hljs-keyword">shell</span>/F-Sy-H . main</code></pre>

  <hr /><h3 align="left">Oh-My-Zsh</h3>

  <p>Clone the Repository.</p>

<pre><code class="lang-zsh">git clone <span class="hljs-string">https:</span>//github.com/z-shell/F-Sy-H.git \
  ${<span class="hljs-string">ZSH_CUSTOM:</span>-$HOME<span class="hljs-regexp">/.oh-my-zsh/</span>custom}<span class="hljs-regexp">/plugins/</span>F-Sy-H</code></pre>

<p>And add <code>F-Sy-H</code> to your plugin list.</p>

<hr /><h2 align="left">Features</h2>

  <hr /><h3 align="left">Themes</h3>

  <p>Switch themes via <code>fast-theme {theme-name}</code>.</p>

<div
style="
  width: 100%;
  background-color: black;
  border: 3px solid black;
  border-radius: 6px;
  margin: 5px 0;
  padding: 2px 5px;
"
>
<img src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/theme.png"
alt="image could not be loaded"
style="color: red; background-color: black; font-weight: bold"
/></div>

<p>Run <code>fast-theme -t {theme-name}</code> option to obtain the snippet above.</p><p>
Run <code>fast-theme -l</code> to list available themes.</p>

  <hr /><h3 align="left">Variables</h3>

<p>Compared to the project <code>zsh-users/zsh-syntax-highlighting</code> (the
upper line):</p>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/parameter.png"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/in_string.png"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <hr /><h3 align="left">Brackets</h3>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/brackets.gif"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <hr /><h3 align="left">Conditions</h3>

  <p>
    Comparing to the project <code>zsh-users/zsh-syntax-highlighting</code> (the
    upper line):
  </p>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/cplx_cond.png"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <hr /><h3 align="left">Strings</h3>

  <p>Exact highlighting that recognizes quotes.</p>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/ideal-string.png"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <hr /><h3 align="left">here-strings</h3>

<div
style="
  width: 100%;
  background-color: black;
  border: 3px solid black;
  border-radius: 6px;
  margin: 5px 0;
  padding: 2px 5px;
"
>
<img src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/herestring.png" alt="image could not be loaded"
style="color: red; background-color: black; font-weight: bold" />
</div>

  <hr /><h3 align="left"><code>exec</code> descriptor-variables</h3>

  <p>
    Comparing to the project
    upper line):
  </p>

<div
style="
  width: 100%;
  background-color: black;
  border: 3px solid black;
  border-radius: 6px;
  margin: 5px 0;
  padding: 2px 5px;
"
><img src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/execfd_cmp.png" alt="image could not be loaded" style="color: red; background-color: black; font-weight: bold" />
</div>

  <hr /><h3 align="left">
    for-loops and alternate syntax (brace <code>{`/`}</code> blocks)
  </h3>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/for-loop-cmp.png"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <hr /><h3 align="left">Function definitions</h3>

  <p>
    Comparing to the project <code>zsh-users/zsh-syntax-highlighting</code> (the
    upper 2 lines):
  </p>

<div
style="
  width: 100%;
  background-color: black;
  border: 3px solid black;
  border-radius: 6px;
  margin: 5px 0;
  padding: 2px 5px;
"
><img src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/function.png"
alt="image could not be loaded" style="color: red; background-color: black; font-weight: bold" /></div>

  <hr /><h3 align="left">
    Recursive <code>eval</code> and <code>$( )</code> highlighting
  </h3>

  <p>
    Comparing to the project <code>zsh-users/zsh-syntax-highlighting</code> (the
    upper line):
  </p>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/eval_cmp.png"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <hr /><h3 align="left">Chroma functions</h3>

  <p>Highlighting that is specific for a given command.</p>

<div
  style="
    width: 100%;
    background-color: black;
    border: 3px solid black;
    border-radius: 6px;
    margin: 5px 0;
    padding: 2px 5px;
  "
  >
<img src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/git_chroma.png"
alt="image could not be loaded"
style="color: red; background-color: black; font-weight: bold" />
</div>

<p>The <a href="https://github.com/z-shell/F-Sy-H/tree/main/%E2%86%92chroma">chromas</a> that are enabled by default can be found <a href="https://github.com/z-shell/F-Sy-H/blob/main/functions/fast-highlight#L172">here</a>.</p>

  <hr /><h3 align="left">Math-mode highlighting</h3>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/math.gif"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>

  <hr /><h3 align="left">Zcalc highlighting</h3>

  <div
    style="
      width: 100%;
      background-color: black;
      border: 3px solid black;
      border-radius: 6px;
      margin: 5px 0;
      padding: 2px 5px;
    "
  >
    <img
      src="https://raw.githubusercontent.com/z-shell/F-Sy-H/main/docs/images/zcalc.png"
      alt="image could not be loaded"
      style="color: red; background-color: black; font-weight: bold"
    />
  </div>
  <h2 align="left">Performance</h2>

  <p>
    Performance differences can be observed in this Asciinema recording,where a
    `10 kB` function is being edited.
  </p>
  <p>
    <a href="https://asciinema.org/a/112367">
      <img src="https://asciinema.org/a/112367.png" alt="asciicast" />
    </a>
  </p>
<hr /><h2 align="left">Credits</h2>
<p align="center">
<a href="https://trunk.io" rel="nofollow">
  <img align="center" width="140px" height="40px" src="https://storage.googleapis.com/digital-space/img/brand/trunk/trunk-white.svg" alt="Trunk" />
</a>
<a href="https://crowdin.com/?utm_source=badge&utm_medium=referral&utm_campaign=badge-add-on" rel="nofollow">
  <img align="center" width="140px" height="40px" src="https://storage.googleapis.com/digital-space/img/brand/crowdin/localization-at-dark-rounded%402x.png" alt="Crowdin | Agile localization for tech companie" />
</a>
<a href="https://www.digitalocean.com/?refcode=090bdb63f800&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge" rel="nofollow">
  <img align="center" width="140px" height="40px" src="https://web-platforms.sfo2.digitaloceanspaces.com/WWW/Badge%203.svg" alt="DigitalOcean Referral Badge" />
</a>
<a href="https://cloudflare.com" rel="nofollow">
  <img align="center" width="140px" height="40px" src="https://storage.googleapis.com/digital-space/img/brand/cloudflare/cf-logo-v-rgb.png" alt="Cloudflare" />
</a>
<p>
