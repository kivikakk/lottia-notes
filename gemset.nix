{
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15s8van7r2ad3dq6i03l3z4hqnvxcq75a3h72kxvf9an53sqma20";
      type = "gem";
    };
    version = "2.8.4";
  };
  adsf = {
    dependencies = ["rack" "rackup"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bi3szzcwb5g1iia9jzz0pjg6clvmpf3k73nx2zqi9jbxi9i74c5";
      type = "gem";
    };
    version = "1.4.7";
  };
  adsf-live = {
    dependencies = ["adsf" "em-websocket" "eventmachine" "listen" "rack-livereload"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16i4gd7jhf9n0hmk7wwb4g38n099s13xr64kfkmasjx54kavi5bz";
      type = "gem";
    };
    version = "1.4.7";
  };
  builder = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  colored = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b0x5jmsyi0z69bm6sij1k89z7h0laag3cb4mdn7zkl9qmxb90lx";
      type = "gem";
    };
    version = "1.2";
  };
  concurrent-ruby = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0krcwb6mn0iklajwngwsg850nk8k9b35dhmc2qkbdqvmifdi2y9q";
      type = "gem";
    };
    version = "1.2.2";
  };
  cri = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bhsgnjav94mz5vf3305gxz1g34gm9kxvnrn1dkz530r8bpj0hr5";
      type = "gem";
    };
    version = "2.15.11";
  };
  ddmetrics = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0in0hk546q3js6qghbifjqvab6clyx5fjrwd3lcb0mk1ihmadyn2";
      type = "gem";
    };
    version = "1.0.1";
  };
  ddplugin = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14hbvr6qjcn1i6pin8rq9kr02f98imskhrl8k53117mlfxxhl9sv";
      type = "gem";
    };
    version = "1.0.3";
  };
  diff-lcs = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rwvjahnp7cpmracd8x732rjgnilqv2sx7d1gfrysslc3h039fa9";
      type = "gem";
    };
    version = "1.5.0";
  };
  em-websocket = {
    dependencies = ["eventmachine" "http_parser.rb"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a66b0kjk6jx7pai9gc7i27zd0a128gy73nmas98gjz6wjyr4spm";
      type = "gem";
    };
    version = "0.5.3";
  };
  eventmachine = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
    version = "1.2.7";
  };
  ffi = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1862ydmclzy1a0cjbvm8dz7847d9rch495ib0zb64y84d3xd4bkg";
      type = "gem";
    };
    version = "1.15.5";
  };
  "http_parser.rb" = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gj4fmls0mf52dlr928gaq0c0cb0m3aqa9kaa6l0ikl2zbqk42as";
      type = "gem";
    };
    version = "0.8.0";
  };
  immutable-ruby = {
    dependencies = ["concurrent-ruby" "sorted_set"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mbfcy85nn527inyi4qbv1cqmz2sivb6bzjrfvgi8agz6w0ns5ry";
      type = "gem";
    };
    version = "0.1.0";
  };
  json_schema = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nzcnb9j7bbj3nc6izwlsxky8j4xly345qzfg5v5n6550kqfmqfn";
      type = "gem";
    };
    version = "0.21.0";
  };
  listen = {
    dependencies = ["rb-fsevent" "rb-inotify"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13rgkfar8pp31z1aamxf5y7cfq88wv6rxxcwy7cmm177qq508ycn";
      type = "gem";
    };
    version = "3.8.0";
  };
  memo_wise = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04jsccp6zp8rhavyflhxf95m6fwz2qsj1xzcbkj3hjhfx4x91pq5";
      type = "gem";
    };
    version = "1.7.0";
  };
  nanoc = {
    dependencies = ["addressable" "colored" "nanoc-checking" "nanoc-cli" "nanoc-core" "nanoc-deploying" "parallel" "tty-command" "tty-which"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0p7lslkk7qlxsj4w47flxl58lildxra3px2ymc9f59g77s0syh1p";
      type = "gem";
    };
    version = "4.12.16";
  };
  nanoc-checking = {
    dependencies = ["nanoc-cli" "nanoc-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0inr8nmz3s3c96v7z6vhnrb2jycq3lhn5jk0scfxkzjbq541bccx";
      type = "gem";
    };
    version = "1.0.2";
  };
  nanoc-cli = {
    dependencies = ["cri" "diff-lcs" "nanoc-core" "zeitwerk"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fxz6dzqd3krpyvbrijkafhd7gpa87zlxygnqcy3p4rb7qh0hm8f";
      type = "gem";
    };
    version = "4.12.16";
  };
  nanoc-core = {
    dependencies = ["concurrent-ruby" "ddmetrics" "ddplugin" "immutable-ruby" "json_schema" "memo_wise" "psych" "slow_enumerator_tools" "tty-platform" "zeitwerk"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jgd0ncfm258180glckvhn0xi70rm0mxi1kmlmkisa3jag9xdvsp";
      type = "gem";
    };
    version = "4.12.16";
  };
  nanoc-deploying = {
    dependencies = ["nanoc-checking" "nanoc-cli" "nanoc-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05s3aqdb7li97lzj5qpak8iac2nfhggv5s23wmzmgzm16c7fkcw9";
      type = "gem";
    };
    version = "1.0.2";
  };
  nanoc-live = {
    dependencies = ["adsf-live" "listen" "nanoc-cli" "nanoc-core"];
    groups = ["nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mnyibl977narr9k6n9wz3cpry03vkc5bwffnxbv34qfp873dqx7";
      type = "gem";
    };
    version = "1.0.0";
  };
  parallel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jcc512l38c0c163ni3jgskvq1vc3mr8ly5pvjijzwvfml9lf597";
      type = "gem";
    };
    version = "1.23.0";
  };
  pastel = {
    dependencies = ["tty-color"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xash2gj08dfjvq4hy6l1z22s5v30fhizwgs10d6nviggpxsj7a8";
      type = "gem";
    };
    version = "0.8.0";
  };
  psych = {
    dependencies = ["stringio"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xmq609h7j0xjr7jwayg8kmvcpp347cp0wnyq7jgpn58vk1ja17p";
      type = "gem";
    };
    version = "4.0.6";
  };
  public_suffix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hz0bx2qs2pwb0bwazzsah03ilpf3aai8b7lk7s35jsfzwbkjq35";
      type = "gem";
    };
    version = "5.0.1";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11v3l46mwnlzlc371wr3x6yylpgafgwdf0q7hc7c1lzx6r414r5g";
      type = "gem";
    };
    version = "1.7.1";
  };
  rack = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j3j8lxb3pda25lq9l3661rjd99a3z2ky6cqxbg7sdmvnwpr2b4w";
      type = "gem";
    };
    version = "3.0.8";
  };
  rack-livereload = {
    dependencies = ["rack"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gwc4w6n63hdjry4z1v3ws6s55bzh9lh6vb22631jv2dny96bhca";
      type = "gem";
    };
    version = "0.5.1";
  };
  rackup = {
    dependencies = ["rack" "webrick"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kbcka30g681cqasw47pq93fxjscq7yvs5zf8lp3740rb158ijvf";
      type = "gem";
    };
    version = "2.1.0";
  };
  rb-fsevent = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zmf31rnpm8553lqwibvv3kkx0v7majm1f341xbxc0bk5sbhp423";
      type = "gem";
    };
    version = "0.11.2";
  };
  rb-inotify = {
    dependencies = ["ffi"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
      type = "gem";
    };
    version = "0.10.1";
  };
  rbtree = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z0h1x7fpkzxamnvbw1nry64qd6n0nqkwprfair29z94kd3a9vhl";
      type = "gem";
    };
    version = "0.4.6";
  };
  rouge = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pym2zjwl6dwdfvbn7rbvmds32r70jx9qddhvvi6pqy6987ack1v";
      type = "gem";
    };
    version = "4.1.2";
  };
  set = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07kc057nrkddrybqmlbmgf9x7nsmbc3ni6gy1z6xjx5b838vlj33";
      type = "gem";
    };
    version = "1.0.3";
  };
  slow_enumerator_tools = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0phfj4jxymxf344cgksqahsgy83wfrwrlr913mrsq2c33j7mj6p6";
      type = "gem";
    };
    version = "1.1.0";
  };
  sorted_set = {
    dependencies = ["rbtree" "set"];
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0brpwv68d7m9qbf5js4bg8bmg4v7h4ghz312jv9cnnccdvp8nasg";
      type = "gem";
    };
    version = "1.0.3";
  };
  stringio = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0557v4z7996cgqw7i9197848mymv02krads93dn9lyqa5d7xd0dn";
      type = "gem";
    };
    version = "3.0.7";
  };
  tty-color = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0aik4kmhwwrmkysha7qibi2nyzb4c8kp42bd5vxnf8sf7b53g73g";
      type = "gem";
    };
    version = "0.6.0";
  };
  tty-command = {
    dependencies = ["pastel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14hi8xiahfrrnydw6g3i30lxvvz90wp4xsrlhx8mabckrcglfv0c";
      type = "gem";
    };
    version = "0.10.1";
  };
  tty-platform = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02h58a8yg2kzybhqqrhh4lfdl9nm0i62nd9jrvwinjp802qkffg2";
      type = "gem";
    };
    version = "0.3.0";
  };
  tty-which = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rpljdwlfm4qgps2xvq6306w86fm057m89j4gizcji371mgha92q";
      type = "gem";
    };
    version = "0.5.0";
  };
  webrick = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13qm7s0gr2pmfcl7dxrmq38asaza4w0i2n9my4yzs499j731wh8r";
      type = "gem";
    };
    version = "1.8.1";
  };
  zeitwerk = {
    groups = ["default" "nanoc"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ck6bj7wa73dkdh13735jl06k6cfny98glxjkas82aivlmyzqqbk";
      type = "gem";
    };
    version = "2.6.8";
  };
}
