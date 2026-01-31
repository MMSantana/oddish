defmodule Oddish.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OddishWeb.Telemetry,
      Oddish.Repo,
      {DNSCluster, query: Application.get_env(:oddish, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Oddish.PubSub},
      # Start a worker by calling: Oddish.Worker.start_link(arg)
      # {Oddish.Worker, arg},
      # Start to serve requests, typically the last entry
      OddishWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Oddish.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OddishWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
