defmodule Oddish.Repo do
  use Ecto.Repo,
    otp_app: :oddish,
    adapter: Ecto.Adapters.Postgres
end
