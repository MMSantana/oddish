defmodule Oddish.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Oddish.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias Oddish.Accounts
  alias Oddish.Accounts.{User, Organization}

  defstruct user: nil, organization: nil

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{} = user) do
    %__MODULE__{user: user}
  end

  def for_user(nil), do: nil

  def put_organization(%__MODULE__{} = scope, %Organization{} = organization) do
    %{scope | organization: organization}
  end

  def for(opts) when is_list(opts) do
    cond do
      opts[:user] && opts[:org] ->
        user = user(opts[:user])
        org = org(opts[:org])

        user
        |> for_user()
        |> put_organization(org)

      opts[:user] ->
        user = user(opts[:user])
        for_user(user)

      opts[:org] ->
        %__MODULE__{organization: org(opts[:org])}
    end
  end

  defp user(id) when is_integer(id) do
    Accounts.get_user!(id)
  end

  defp user(email) when is_binary(email) do
    Accounts.get_user_by_email(email)
  end

  defp org(id) when is_integer(id) do
    Organization.get_organization!(id)
  end

  defp org(slug) when is_binary(slug) do
    Organization.get_organization_by_slug!(slug)
  end
end
