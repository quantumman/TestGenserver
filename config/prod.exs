use Mix.Config

config :webappExternalProcess, WebappExternalProcess.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [scheme: "http", host: "cryptic-cliffs-6144.heroku.com", port: 80],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json"

config :logger, level: :info

config :webappExternalProcess, WebappExternalProcess.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :webappExternalProcess, WebappExternalProcess.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20
