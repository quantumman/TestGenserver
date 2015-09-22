defmodule WebappExternalProcess do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(WebappExternalProcess.Endpoint, []),
      # Start the Ecto repository
      worker(WebappExternalProcess.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(WebappExternalProcess.Worker, [arg1, arg2, arg3]),
      worker(RubyServer, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WebappExternalProcess.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WebappExternalProcess.Endpoint.config_change(changed, removed)
    :ok
  end

  def test(_) do
    {:ok, server} = RubyServer.start_link

    RubyServer.cast(server, ~S"""
    require "asciidoctor"
    Asciidoctor.convert #{source}, header_footer: true, safe: 'safe'
    """)
  end
end
