ikbot
=====

A hipchat bot written in Elixir.

![](https://s3.amazonaws.com/uploads.hipchat.com/15025/56179/XIdgtXwdZ5BNo78/ikbot.jpg)

Requirements
=====

* Elixir 1.0.1


Clone
=====

```
$ git clone git@github.com:inaka/ikbot.git
```

Configuration
====
Copy the content from config/config.exs.template to config/config.exs and replace
the **** with your information. and also select the scripts that you want to use, updating
the 'scripts' list.

Example:

*config/config.exs*
```
use Mix.Config
config :ikbot,
  scripts:
    [
      "base",
      "devops"
    ],
  bing:
    %{
      key: 'bing_key_to_allow_search_images'
    }

config :hedwig,
  clients: [
    %{
      jid: "123_456@chat.hipchat.com",
      password: "your_secret_pwd",
      nickname: "ik bot",
      resource: "ikbot",
      config: %{
        server: "chat.hipchat.com",
        port: 5222,
        require_tls?: true,
        use_compression?: false,
        use_stream_management?: false,
        transport: :tcp
      },
      rooms: [
        "16054_botroom@conf.hipchat.com"
      ],
      handlers: [
        {Ikbot.Hipchat, %{}}
      ]
    }
  ]
```


Run it
====
```
$ cd ikbot
$ mix deps.get
$ mix app
$ iex -S mix
```

Contact Us
==========

For **questions** or **general comments** regarding the use of this library, please use our public
[hipchat room](https://www.hipchat.com/gpBpW3SsT).

If you find any **bugs** or have a **problem** while using this library, please [open an issue](https://github.com/inaka/ikbot/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at [inaka.github.io](http://inaka.github.io)
