{ isWSL, inputs, currentSystemUser, ... }:

{ config, lib, pkgs, ... }:

let
  sources = import ../../npins/default.nix;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  #---------------------------------------------------------------------
  # VS Code extensions not available in nixpkgs
  #---------------------------------------------------------------------
  sjurmillidahl.ormolu-vscode = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    nativeBuildInputs = with pkgs; [
      jq
      moreutils
    ];

    mktplcRef = {
      name = "ormolu-vscode";
      publisher = "sjurmillidahl";
      version = "0.0.10";
      hash = "sha256-FJvxD4UcuNzdFAeOSFlwtGn9WDqs0Zl1uEvnTcI7yo0=";
    };

    postInstall = ''
      cd "$out/$installPrefix"
      jq '.contributes.configuration.properties."ormolu.path".default = "${pkgs.ormolu}/bin/ormolu"' package.json | sponge package.json
    '';
  };

  #---------------------------------------------------------------------
  # Tmux plugins not available in nixpkgs
  #---------------------------------------------------------------------
  tmux-themepack = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-themepack";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "jimeh";
      repo = "tmux-themepack";
      rev = "7c59902f64dcd7ea356e891274b21144d1ea5948";
      sha256 = "sha256-c5EGBrKcrqHWTKpCEhxYfxPeERFrbTuDfcQhsUAbic4=";
    };
    postInstall = ''
      sed -i -e 's|tmux |${pkgs.tmux}/bin/tmux |g' $target/themepack.tmux
    '';
  };

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
    bat --language man --style plain
    '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  ''));

  shellAliases = {
    gut = "git";
    gti = "git";
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gd = "git diff";
    gl = "git prettylog";
    gp = "git push";
    gs = "git status";
    gt = "git tag";
  };
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    pkgs._1password-cli
    pkgs.asciinema
    pkgs.bat
    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    # pkgs.sentry-cli
    pkgs.tree
    pkgs.watch

    # pkgs.gopls
    # pkgs.zigpkgs."0.13.0"

    pkgs.nodejs
    pkgs.python312
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
    pkgs.tailscale
  ]) ++ (lib.optionals (isLinux && !isWSL) [
    pkgs.chromium
    pkgs.firefox
    pkgs.rofi
    pkgs.valgrind
    pkgs.zathura
    pkgs.xfce.xfce4-terminal
  ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    EDITOR = "vim";
    HOMEBREW_AUTO_UPDATE_SECS = 604800; # One week
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    MANPAGER = "${manpager}/bin/manpager";
    PAGER = "less -FirSwX";
  } // (builtins.fromJSON (builtins.readFile ../../secret/config.json)).environment_variables;

  home.file = {
    ".psqlrc".source = ./psqlrc;
  #   ".gdbinit".source = ./gdbinit;
  #   ".inputrc".source = ./inputrc;
  } // (if isDarwin then {
  #   "Library/Application Support/jj/config.toml".source = ./jujutsu.toml;
  } else {});

  xdg = {
    enable = true;
    configFile = (if isDarwin then {
      "rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;
    } else {});
  };
  # xdg.enable = true;
  # xdg.configFile = {
  #   "i3/config".text = builtins.readFile ./i3;
  #   "rofi/config.rasi".text = builtins.readFile ./rofi;

  #   # tree-sitter parsers
  #   "nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  #   "nvim/queries/proto/folds.scm".source =
  #     "${sources.tree-sitter-proto}/queries/folds.scm";
  #   "nvim/queries/proto/highlights.scm".source =
  #     "${sources.tree-sitter-proto}/queries/highlights.scm";
  #   "nvim/queries/proto/textobjects.scm".source =
  #     ./textobjects.scm;
  # } // (if isDarwin then {
  #   # Rectangle.app. This has to be imported manually using the app.
  #   "rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;
  # } else {}) // (if isLinux then {
  #   "ghostty/config".text = builtins.readFile ./ghostty.linux;
  #   "jj/config.toml".source = ./jujutsu.toml;
  # } else {});

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = !isDarwin;

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    inherit shellAliases;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # Called 4th
    initExtra = builtins.readFile ./zshrc;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    syntaxHighlighting.enable = true;
    # Called 3rd
    initExtraBeforeCompInit = ''
    '';
    # Called 2nd
    initExtraFirst = ''
    '';
    # Called 5th
    loginExtra = ''
    '';
    logoutExtra = ''
    '';
    # Called 1st
    profileExtra = ''
    '';

    inherit shellAliases;
  };

  programs.direnv = {
    enable = true;

    config = {
      whitelist = {
        # prefix= [
        #   "$HOME/code/go/src/github.com/@@github.user@@"
        # ];

        exact = ["$HOME/.envrc"];
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "@@programs.git.userName@@";
    userEmail = "@@programs.git.userEmail@@";
    signing = {
      key = "@@programs.git.signing.key@@";
      signByDefault = true;
    };
    aliases = {
      amend = "commit --amend";
      cm = "commit -m";
      co = "checkout";
      po = "push origin";
      pr = "pull -r -p";
      s = "status";
      size = "count-objects -vH";
      undo = "reset HEAD~";
      zip = "archive --format=zip --output project.zip HEAD";
      cleanup = "!git branch --merged | grep  -v '\\*\\|main\\|develop' | xargs -n 1 -r git branch -d";
      # Invoke it like this: git h -- <file>
      h = "log -p --follow";
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "@@github.user@@";
      init.defaultBranch = "main";
      push.authSetupRemote = true;
      push.default = "tracking";
      rebase.autoStash = true;
      # gpg.format = "ssh";
      # user.signingkey = "@@ssh.key.path@@.pub";
    };
  };

  # programs.go = {
  #   enable = true;
  #   goPath = "code/go";
  #   goPrivate = [ "github.com/@@github.user@@" ];
  # };

  programs.vscode = {
    enable = true;
    userSettings = {
      "cloudcode.apigee.dockerOptions" = {
        "environmentVariables" = {
          "XTERM" = "xterm-256color";
        };
        "dns" = "8.8.8.8";
        "detached" = true;
        "privileged" = true;
        "labels" = {};
        "volumes" = {};
        "additionalArguments" = "";
      };
      "debug.javascript.autoAttachFilter" = "disabled";
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.renderWhitespace" = "all";
      "editor.minimap.enabled" = false;
      "editor.formatOnSave" = false;
      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = "explicit";
        # "source.organizeImports" = "explicit";
      };
      "editor.tabSize" = 2;
      "eslint.codeActionsOnSave.mode" = "problems";
      # "eslint.enable" = true;
      # "eslint.format.enable" = true;
      # "eslint.validate" = [
      #   "javascript"
      #   "javascriptreact"
      #   "typescript"
      #   "typescriptreact"
      # ];
      "explorer.confirmDragAndDrop" = false;
      "files.associations" = {
        "*.libjsonnet" = "jsonnet";
        "*.jsonnet" = "jsonnet";
        "*.json" = "json";
      };
      "files.watcherExclude" = {
        "**/.bloop" = true;
        "**/.metals" = true;
        "**/.ammonite" = true;
      };
      "files.insertFinalNewline" = true;
      "files.trimTrailingWhitespace" = true;
      "git.ignoreMissingGitWarning" = true;
      "haskell.manageHLS" = "GHCup";
      # "metals.javaHome" = "~/Library/Caches/Coursier/arc/https/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.15%252B10/OpenJDK11U-jdk_x64_mac_hotspot_11.0.15_10.tar.gz/jdk-11.0.15+10/Contents/Home";
      "notebook.lineNumbers" = "on";
      "json.schemas" = [];
      "plantuml.server" = "http://localhost:9090";
      "plantuml.render" = "PlantUMLServer";
      "prettier.trailingComma" = "all";
      "python.defaultInterpreterPath" = "${pkgs.python312}/bin/python3";
      "python.analysis.typeCheckingMode" = "strict";
      "python.formatting.provider" = "autopep8";
      "redhat.telemetry.enabled" = false;
      "terminal.integrated.defaultProfile.windows" = "";
      "terminal.integrated.inheritEnv" = false;
      "typescript.preferences.importModuleSpecifier" = "non-relative";
      # "vs-kubernetes" = {
      #   "vscode-kubernetes.minikube-path.mac" = "~/.vs-kubernetes/tools/minikube/darwin-amd64/minikube";
      # };
      "window.autoDetectColorScheme" = true;
      "window.confirmBeforeClose" = "keyboardOnly";
      "[dockercompose]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[dockerfile]" = {
        "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
      };
      "[go]" = {
        "editor.insertSpaces" = false;
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
        "editor.suggest.snippetsPreventQuickSuggestions" = false;
      };
      "[haskell]" = {
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
        "editor.defaultFormatter" = "sjurmillidahl.ormolu-vscode";
      };
      "[jinja-shell]" = {
        "editor.formatOnSave" = false;
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[json]" = {
        "editor.tabSize" = 2;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[jsonc]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[jsonnet]" = {
        "editor.defaultFormatter" = "Sebbia.jsonnetng";
      };
      "[mermaid]" = {
        "editor.formatOnSave" = false;
      };
      "[nix]" = {
        "editor.autoIndent" = "full";
      };
      "[plantuml]" = {
        "editor.tabSize" = 2;
      };
      "[python]" = {
        "editor.formatOnSave" = true;
        "editor.wordBasedSuggestions" = "matchingDocuments";
        "editor.tabSize" = 4;
      };
      "[r]" = {
        "editor.defaultFormatter" = "Ikuyadeu.r";
        "editor.formatOnSave" = true;
        "editor.wordSeparators" = "`~!@#%$^&*()-=+[{]}\\|;:'\",<>/?";
      };
      "[rmd]" = {
        "editor.defaultFormatter" = "Ikuyadeu.r";
        "editor.formatOnSave" = true;
      };
      "[scala]" = {
        "editor.suggestSelection" = "first";
        "editor.formatOnPaste" = true;
        "editor.formatOnType" = true;
        "editor.tabSize" = 2;
      };
      "[typescript]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.tabSize" = 2;
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[xml]" = {
        "editor.autoClosingBrackets" = "never";
        "editor.formatOnSave" = false;
        "editor.tabSize" = 2;
        "files.trimFinalNewlines" = true;
      };
      "[yaml]" = {
        "editor.insertSpaces" = true;
        "editor.tabSize" = 2;
        "editor.autoIndent" = "advanced";
        "diffEditor.ignoreTrimWhitespace" = false;
        "gitlens.codeLens.scopes" = [
          "document"
        ];
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
    };
    extensions = with pkgs.vscode-extensions; [
      # arcanis.vscode-zipfs
      # googlecloudtools.cloudcode
      # jcanero.hoogle-vscode
      # lextudio.restructuredtext
      # mathematic.vscode-pdf
      # ms-ossdata.vscode-postgresql
      # ms-vscode.remote-explorer
      # trond-snekvik.simple-rst
      # visortelle.haskell-spotlight
      bbenoist.nix
      bierner.markdown-mermaid
      dbaeumer.vscode-eslint
      eamodio.gitlens
      esbenp.prettier-vscode
      github.copilot
      github.copilot-chat
      github.vscode-github-actions
      github.vscode-pull-request-github
      hashicorp.terraform
      haskell.haskell
      justusadam.language-haskell
      mathiasfrohlich.kotlin
      ms-azuretools.vscode-docker
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.debugpy
      ms-python.isort
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.vscode-jupyter-slideshow
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.live-server
      ms-vscode.makefile-tools
      redhat.vscode-yaml
      reditorsupport.r
      scala-lang.scala
      scalameta.metals
      sjurmillidahl.ormolu-vscode
      vscodevim.vim
    ];
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "l";
    secureSocket = false;
    mouse = true;
    plugins = [
      pkgs.tmuxPlugins.continuum
      pkgs.tmuxPlugins.pain-control
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.sessionist
      pkgs.tmuxPlugins.yank
      tmux-themepack
    ];

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false

      set -g @themepack 'powerline/block/cyan'

      bind -n C-k send-keys "clear"\; send-keys "Enter"
      # Copy on ^M to system clipboard
      # bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
      # unbind [
      # bind Escape copy-mode
      # unbind p
      # bind p paste-buffer
      # bind-key -t vi-copy 'v' begin-selection
      # bind-key -t vi-copy 'y' copy-selection

      # set-option -g prefix C-a
      set-option -g allow-rename off
      set-option -g status-right '[#h###S:#I:#P]'

      set-window-option -g mode-keys vi

      run-shell ${pkgs.tmuxPlugins.pain-control}/pain_control.tmux
      run-shell ${pkgs.tmuxPlugins.dracula}/dracula.tmux
      run-shell ${tmux-themepack}/themepack.tmux

      # See https://github.com/tmux-plugins/tpm?tab=readme-ov-file#installation
      # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
      # run-shell {tpm}/tpm
    '';
  };

  services.gpg-agent = {
    enable = isLinux;
    pinentryPackage = pkgs.pinentry-tty;

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = lib.mkIf (isLinux && !isWSL) {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}
